locals {
  # Application configuration - CHANGE THESE VALUES FOR NEW APPS
  app_name          = "gws-mcp"
  aws_region        = var.AWS_REGION
  cloudflare_domain = var.CLOUDFLARE_DOMAIN
  # Environment-specific configuration (from .tfvars)
  environment          = var.ENVIRONMENT
  cloudflare_subdomain = var.ENVIRONMENT == "prod" ? "google-workspace-mcp" : var.ENVIRONMENT == "staging" ? "google-workspace-mcp-staging" : "google-workspace-mcp-dev"

  # Derived names - DO NOT CHANGE BELOW THIS LINE
  name_prefix = var.ENVIRONMENT == "staging" ? "${local.app_name}-stag" : "${local.app_name}-${local.environment}"

  # VPC and SSH key configuration
  ssh_key_name = "${local.name_prefix}-key"

  # Shared VPC configuration
  vpc_id                   = data.terraform_remote_state.shared_vpc.outputs.vpc_id
  vpc_cidr                 = data.terraform_remote_state.shared_vpc.outputs.vpc_cidr
  igw_id                   = data.terraform_remote_state.shared_vpc.outputs.igw_id
  igw                      = data.terraform_remote_state.shared_vpc.outputs.igw
  nat_network_interface_id = data.terraform_remote_state.shared_vpc.outputs.nat_network_interface_id

  # Subnet configuration
  subnet_cidrs = {
    dev = {
      public_1  = "10.1.77.0/24"
      public_2  = "10.1.78.0/24"
      private_1 = "10.1.79.0/24"
      private_2 = "10.1.80.0/24"
    }
    staging = {
      public_1  = "10.2.252.0/24"
      public_2  = "10.2.253.0/24"
      private_1 = "10.2.254.0/24"
      private_2 = "10.2.255.0/24"
    }
    prod = {
      public_1  = "10.2.81.0/24"
      public_2  = "10.2.82.0/24"
      private_1 = "10.2.83.0/24"
      private_2 = "10.2.84.0/24"
    }
  }
  public_subnet_1_cidr_block  = local.subnet_cidrs[local.environment].public_1
  public_subnet_2_cidr_block  = local.subnet_cidrs[local.environment].public_2
  private_subnet_1_cidr_block = local.subnet_cidrs[local.environment].private_1
  private_subnet_2_cidr_block = local.subnet_cidrs[local.environment].private_2

  availability_zone_a = "ap-southeast-1a"
  availability_zone_b = "ap-southeast-1b"

  # ECS instance configuration
  ecs_instance_type = "t4g.small"

  # ECS cluster and task configuration
  ecs_task_family_name         = "${local.name_prefix}-task-family"
  ecs_task_execution_role_name = "${local.name_prefix}-task-execution-role"

  # Container configuration
  container_name             = "${local.name_prefix}-app-container"
  container_cpu              = 512
  container_memory           = 1024
  container_port             = 8000
  container_os               = "LINUX"
  container_cpu_architecture = "ARM64"

  # ECS cluster and service configuration
  ecs_cluster_name          = "${local.name_prefix}-ecs-cluster"
  ecs_service_name          = "${local.name_prefix}-app-service"
  ecs_service_desired_count = 1

  # Load balancer configuration
  application_load_balancer_name = "${local.name_prefix}-alb"

  # Auto Scaling Group configuration
  asg_name                      = "${local.name_prefix}-asg"
  asg_desired_capacity          = 1
  asg_min_size                  = 1
  asg_max_size                  = 3
  asg_min_scaling_step          = 1
  asg_max_scaling_step          = 1
  asg_target_capacity           = 100
  asg_scale_out_cpu_utilization = 70
  asg_scale_in_cpu_utilization  = 30

  # ECS service auto scaling configuration
  ecs_service_min_count              = 1
  ecs_service_max_count              = 6
  ecs_service_target_cpu_utilization = 75
  ecs_service_scale_in_cooldown      = 300
  ecs_service_scale_out_cooldown     = 60

  # CloudWatch logs configuration
  cloudwatch_log_group_name = "/ecs/${local.ecs_cluster_name}/${local.ecs_service_name}"
  awslogs_stream_prefix     = "${local.name_prefix}-ecs"

  # Monitoring configuration
  dev_emails = var.DEV_EMAILS

  # Common tags
  common_tags = {
    Environment = local.environment
    Application = "Google Workspace MCP"
    ManagedBy   = "terraform"
  }

  ecs_env_base = [
    { name = "PORT", value = var.WORKSPACE_MCP_PORT },
    { name = "WORKSPACE_MCP_PORT", value = var.WORKSPACE_MCP_PORT },
    { name = "WORKSPACE_EXTERNAL_URL", value = var.WORKSPACE_EXTERNAL_URL },
    { name = "GOOGLE_OAUTH_CLIENT_ID", value = var.GOOGLE_OAUTH_CLIENT_ID },
    { name = "GOOGLE_OAUTH_CLIENT_SECRET", value = var.GOOGLE_OAUTH_CLIENT_SECRET },
    { name = "MCP_ENABLE_OAUTH21", value = var.MCP_ENABLE_OAUTH21 },
    { name = "WORKSPACE_MCP_STATELESS_MODE", value = var.WORKSPACE_MCP_STATELESS_MODE },
    { name = "EXTERNAL_OAUTH21_PROVIDER", value = var.EXTERNAL_OAUTH21_PROVIDER },
    { name = "TZ", value = "UTC" }
  ]

  ecs_env_optional = [
    { name = "WORKSPACE_MCP_BASE_URI", value = var.WORKSPACE_MCP_BASE_URI },
    { name = "OAUTH_CUSTOM_REDIRECT_URIS", value = var.OAUTH_CUSTOM_REDIRECT_URIS },
    { name = "OAUTH_ALLOWED_ORIGINS", value = var.OAUTH_ALLOWED_ORIGINS },
    { name = "TOOL_TIER", value = var.TOOL_TIER },
    { name = "TOOLS", value = var.TOOLS }
  ]

  ecs_env_vars = concat(local.ecs_env_base, [for env in local.ecs_env_optional : env if env.value != ""])
}
