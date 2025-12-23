# Terraform AWS App Runner Module

This Terraform module provisions an **AWS App Runner service** backed by a **private ECR image**, including all required IAM roles for:

- Pulling images from Amazon ECR
- Allowing the running container to access AWS services (e.g. Secrets Manager)

The module is designed for containerized web applications (Flask, FastAPI, Node, etc.) and supports environment variables, secrets injection, and automatic deployments.

---

## Features

- ✅ AWS App Runner service (ECR-based)
- ✅ App Runner access role (ECR pull permissions)
- ✅ App Runner instance role (runtime AWS API access)
- ✅ Environment variables (plain text)
- ✅ Secrets injection (Secrets Manager / Parameter Store)
- ✅ Auto-deploy on new image push
- ✅ Configurable CPU, memory, health checks
- ✅ Least-privilege IAM design

---

## Requirements

| Name | Version |
|-----|---------|
| terraform | >= 1.5 |
| aws provider | >= 5.0 |

---

## Usage

### Basic Example

```hcl
module "malik_apprunner" {
  source = "./modules/apprunner"

  name             = "malik-ai-dev"
  image_identifier = "123456789012.dkr.ecr.us-east-1.amazonaws.com/malik-ai:latest"
  container_port   = 5001

  cpu    = "1024"
  memory = "2048"

  env = {
    FLASK_ENV = "dev"
  }

  secret_env = {
    MALIK_SECRETS_NAME = "arn:aws:secretsmanager:us-east-1:123456789012:secret:malik-secrets-abc123"
  }

  secretsmanager_arns = [
    "arn:aws:secretsmanager:us-east-1:123456789012:secret:malik-secrets-abc123"
  ]

  tags = {
    Project = "malik-ai"
    Env     = "dev"
  }
}
