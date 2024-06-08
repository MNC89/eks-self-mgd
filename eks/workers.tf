### Worker Nodes ASG ###

resource "aws_autoscaling_group" "fp_asg" {
  name                      = var.asg_name
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_size
  health_check_grace_period = var.asg_health_grace_period
  health_check_type         = var.asg_health_type
  vpc_zone_identifier       = var.asg_pub_sub_ids
  capacity_rebalance        = var.asg_cap_rebalance

  depends_on = [
    aws_iam_role_policy_attachment.node_policy
  ]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_dem_base
      on_demand_percentage_above_base_capacity = var.on_dem_percent_over
      spot_allocation_strategy                 = var.spot_strategy
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.fp_asg_lt.id
        version            = aws_launch_template.fp_asg_lt.latest_version
      }

      override {
        instance_type = var.spot_inst_type[0]
      }

      # override {
      #   instance_type = var.spot_inst_type[1]
      # }

      # override {
      #   instance_type = var.spot_inst_type[2]
      # }
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
  name                                 = var.asg_lt_name
  image_id                             = data.aws_ssm_parameter.eks_worker_ami.value # Use the latest EKS optimized AMI
  instance_initiated_shutdown_behavior = var.asg_lt_inst_shutdown
  key_name                             = var.asg_lt_keypair
  vpc_security_group_ids               = [aws_eks_cluster.fp_eks_cluster.vpc_config[0].cluster_security_group_id, aws_security_group.worker_node_sg.id]

  instance_requirements {
    allowed_instance_types = var.spot_inst_type
    memory_mib {
      min = var.asg_lt_mem
    }
    vcpu_count {
      min = var.asg_lt_vcpu
    }
  }

  block_device_mappings {
    device_name = var.lt_ebs_name

    ebs {
      volume_size = var.lt_ebs_size
      volume_type = var.lt_ebs_type
      iops        = var.lt_ebs_iops
      throughput  = var.lt_ebs_throughput
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
  name        = "${var.wk_name}-sg"
  description = "Communication between the control plane and worker nodes in eks nodegroup "
  vpc_id      = var.vpc_id

  tags = {
    Name                                                  = "${var.wk_name}-sg"
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
  name = "${var.wk_name}-instance-profile"
  role = aws_iam_role.node_iam_role.name
}

resource "aws_iam_role" "node_iam_role" {
  name               = "${var.wk_name}-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  depends_on = [ aws_iam_role.node_iam_role ]
  for_each   = var.worker_policy
  policy_arn = each.value
  role       = aws_iam_role.node_iam_role.name
}

# resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.node_iam_role.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.node_iam_role.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   role       = aws_iam_role.node_iam_role.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.node_iam_role.name
# }
