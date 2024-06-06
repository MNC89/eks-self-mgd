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
    }
  }

  tag {
    key                 = "Name"
    value               = "final-project-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/final-project-eks-cluster-dev"
    value               = "owned"
    propagate_at_launch = true
  }
}

### Worker Nodes Launch Template ###

resource "aws_launch_template" "fp_asg_lt" {
  name                                 = "final-project-asg-lt"
  image_id                             = "ami-0f2ee1b771916c0cb" #can the latest eks optimised image be pulled from ssm?
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = "fp-eks-worker-node-key-pair"
  vpc_security_group_ids               = [aws_eks_cluster.fp_eks_cluster.vpc_config[0].cluster_security_group_id, aws_security_group.worker_node_sg.id]

  instance_requirements {
    allowed_instance_types = ["t3.medium", "t3a.medium", "t2.medium"]
    memory_mib {
      min = 4
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

  iam_instance_profile { #to be configured
    name = "test"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                                  = "final-project-eks-worker-node"
      "kubernetes.io/cluster/final-project-eks-cluster-dev" = "owned"
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
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id            = aws_security_group.worker_node_sg.id
  referenced_security_group_id = aws_eks_cluster.fp_eks_cluster.vpc_config[0].cluster_security_group_id
  description                  = "Allow worker nodes in group eks nodegroup to communicate with control plane (workloads using HTTPS port)"
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_kubelet" {
  security_group_id            = aws_security_group.worker_node_sg.id
  referenced_security_group_id = aws_eks_cluster.fp_eks_cluster.vpc_config[0].cluster_security_group_id
  description                  = "Allow worker nodes in group final-project-eks-nodegroup to communicate with control plane (kubelet and workload TCP ports)"
  from_port                    = 1025
  ip_protocol                  = "tcp"
  to_port                      = 65535
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.worker_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow ssh to worker nodes"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.worker_node_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

