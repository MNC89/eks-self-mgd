### Worker Nodes ASG ###

resource "aws_autoscaling_group" "fp_asg" {
  name                      = "final-project-asg"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.asg_pub_sub_ids
  capacity_rebalance        = true

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.fp_asg_lt.id
        version            = aws_launch_template.fp_asg_lt.latest_version
      }

      override {
        instance_type = "t3.medium"
      }

      override {
        instance_type = "t3a.medium"
      }

      override {
        instance_type = "t2.medium"
      }
    }
  }

  tag {
    key                 = "Name"
    value               = "final-project-eks-worker-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/final-project-eks-cluster-dev"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "aws:eks:cluster-name"
    value               = "final-project-eks-cluster-dev"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

### Worker Nodes Launch Template ###

data "aws_ssm_parameter" "eks_worker_ami" {
  name = "/aws/service/eks/optimized-ami/${var.k8_version}/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "fp_asg_lt" {
  name                                 = "final-project-asg-lt"
  image_id                             = data.aws_ssm_parameter.eks_worker_ami.value # Use the latest EKS optimized AMI
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = "fp-eks-worker-node-key-pair"
  vpc_security_group_ids               = [aws_eks_cluster.fp_eks_cluster.vpc_config[0].cluster_security_group_id, aws_security_group.worker_node_sg.id]

  instance_requirements {
    allowed_instance_types = ["t3.medium", "t3a.medium", "t2.medium"]
    memory_mib {
      min = 4096
    }
    vcpu_count {
      min = 2
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 80
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.node_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                                  = "final-project-eks-worker-node"
      "kubernetes.io/cluster/final-project-eks-cluster-dev" = "owned"
      "aws:eks:cluster-name"                                = "final-project-eks-cluster-dev"
    }
  }

  user_data = base64encode(<<-EOF
                #!/bin/bash
                set -o xtrace
                /etc/eks/bootstrap.sh final-project-eks-cluster-dev 
              EOF
  )
}

### Worker Nodes Security Group ###

resource "aws_security_group" "worker_node_sg" {
  name        = "worker-node-sg"
  description = "Communication between the control plane and worker nodes in eks nodegroup "
  vpc_id      = var.vpc_id

  tags = {
    Name                                                  = "worker-node-sg"
    "kubernetes.io/cluster/final-project-eks-cluster-dev" = "owned"
    "aws:eks:cluster-name"                                = "final-project-eks-cluster-dev"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_self" {
  security_group_id            = aws_security_group.worker_node_sg.id
  referenced_security_group_id = aws_security_group.worker_node_sg.id
  description                  = "Allow all traffic from self"
  ip_protocol                  = "-1"

}

resource "aws_vpc_security_group_ingress_rule" "allow_kubelet" {
  security_group_id            = aws_security_group.worker_node_sg.id
  referenced_security_group_id = aws_eks_cluster.fp_eks_cluster.vpc_config[0].cluster_security_group_id
  description                  = "Allow worker nodes in group final-project-eks-nodegroup to communicate with control plane (kubelet and workload TCP ports)"
  from_port                    = 1025
  ip_protocol                  = "tcp"
  to_port                      = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allow_nlb_nodeport_traffic" {
  security_group_id = aws_security_group.worker_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30000
  ip_protocol       = "tcp"
  to_port           = 32767
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.worker_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all https traffic"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.worker_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all http traffic"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.worker_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow ssh to worker nodes"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4_traffic" {
  security_group_id = aws_security_group.worker_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

### EKS Node IAM Role ###

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "node_instance_profile" {
  name = "fp-eks-worker-node-instance-profile"
  role = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role" "node_iam_role" {
  name               = "fp-eks-worker-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_iam_role.name
}

#SSM role required?
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_iam_role.name
}

