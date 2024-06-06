### Worker Nodes ASG ###

resource "aws_autoscaling_group" "fp_asg" {
  name                      = "final-project-asg"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 3
  health_check_grace_period = 300
  health_check_type         = "EC2"
  availability_zones        = var.asg_pub_sub_ids
  capacity_rebalance        = true

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 20
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.example.id
        version            = aws_launch_template.example.latest_version
      }
    }
  }

  timeouts {
    delete = "15m"
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

