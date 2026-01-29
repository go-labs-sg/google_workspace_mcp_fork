resource "aws_ecs_task_definition" "td" {
  family             = local.ecs_task_family_name
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name                  = local.container_name
      image                 = "${var.ECR_REPO_URI}@${var.ECR_IMAGE_DIGEST}"
      operatingSystemFamily = local.container_os
      cpuArchitecture       = local.container_cpu_architecture
      cpu                   = local.container_cpu
      memory                = local.container_memory
      essential             = true
      portMappings = [
        {
          containerPort = local.container_port
          hostPort      = 0
        }
      ],
      environment = local.ecs_env_vars,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name,
          "awslogs-region"        = var.AWS_REGION,
          "awslogs-stream-prefix" = local.awslogs_stream_prefix,
          "awslogs-create-group"  = "true",
          "mode"                  = "non-blocking"
        }
      }
    }
  ])
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = local.container_cpu
  memory                   = local.container_memory
}

resource "aws_ecs_service" "service" {
  name            = local.ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.td.arn
  desired_count   = local.ecs_service_desired_count

  force_new_deployment = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
    base              = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.http_target_group.arn
    container_name   = local.container_name
    container_port   = local.container_port
  }

  depends_on = [
    aws_lb_target_group.http_target_group,
    aws_lb.alb
  ]

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    echo "Update service desired count to 0 before destroy."
    REGION=$(echo "${self.cluster}" | cut -d':' -f4)
    echo "Region: $REGION"
    aws ecs update-service --region $REGION --cluster "${self.cluster}" --service "${self.name}" --desired-count 0 --force-new-deployment
    echo "Update service command executed successfully."
    EOF
  }

  timeouts {
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = local.ecs_service_max_count
  min_capacity       = local.ecs_service_min_count
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "${local.name_prefix}-ecs-target-tracking-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = local.ecs_service_target_cpu_utilization
    scale_in_cooldown  = local.ecs_service_scale_in_cooldown
    scale_out_cooldown = local.ecs_service_scale_out_cooldown
  }
}
