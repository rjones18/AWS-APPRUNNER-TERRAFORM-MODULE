module "malik_apprunner" {
  source = "../"

  name = "malik-ai-${var.environment}"

  image_identifier = var.ecr_image_uri
  container_port   = 8080

  cpu    = "1024" # 1 vCPU
  memory = "2048" # 2 GB RAM

  auto_deployments_enabled = true

  health_check_path = "/"

  # Optional plain env vars
  env = {
    FLASK_ENV = var.environment
    LOG_LEVEL = "info"
  }

  # Optional: App Runner-injected secrets
  # (If you want App Runner to inject instead of your Python code calling SM)
  secret_env = {
    MALIK_SECRETS_NAME = var.secrets_manager_arn
  }

  # Runtime IAM permissions for your container
  secretsmanager_arns = [
    var.secrets_manager_arn
  ]

  tags = {
    Project     = "malik-ai"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
