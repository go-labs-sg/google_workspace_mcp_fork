resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name       = "${aws_ecs_cluster.ecs_cluster.name}-ec2-provider"
  depends_on = [local.igw]

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = local.asg_max_scaling_step
      minimum_scaling_step_size = local.asg_min_scaling_step
      status                    = "ENABLED"
      target_capacity           = local.asg_target_capacity
      instance_warmup_period    = 300
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}
