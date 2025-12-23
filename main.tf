terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# --------------------------------------------
# IAM: Access role for App Runner to pull from ECR
# --------------------------------------------
data "aws_iam_policy_document" "apprunner_access_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "apprunner_access_role" {
  name               = "${var.name}-apprunner-access"
  assume_role_policy = data.aws_iam_policy_document.apprunner_access_assume.json
  tags               = var.tags
}

# AWS-managed policy allows ECR pulls for App Runner build service
resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  role       = aws_iam_role.apprunner_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# --------------------------------------------
# IAM: Instance role for your app container (runtime AWS API access)
# --------------------------------------------
data "aws_iam_policy_document" "apprunner_instance_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["tasks.apprunner.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "apprunner_instance_role" {
  name               = "${var.name}-apprunner-instance"
  assume_role_policy = data.aws_iam_policy_document.apprunner_instance_assume.json
  tags               = var.tags
}

# Least-privilege: allow Secrets Manager reads for specified ARNs
data "aws_iam_policy_document" "secrets_read" {
  count = length(var.secretsmanager_arns) > 0 ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = var.secretsmanager_arns
  }
}

resource "aws_iam_policy" "secrets_read" {
  count  = length(var.secretsmanager_arns) > 0 ? 1 : 0
  name   = "${var.name}-secrets-read"
  policy = data.aws_iam_policy_document.secrets_read[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "secrets_read_attach" {
  count      = length(var.secretsmanager_arns) > 0 ? 1 : 0
  role       = aws_iam_role.apprunner_instance_role.name
  policy_arn = aws_iam_policy.secrets_read[0].arn
}

# --------------------------------------------
# App Runner service
# --------------------------------------------
resource "aws_apprunner_service" "this" {
  service_name = var.name
  tags         = var.tags

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access_role.arn
    }

    auto_deployments_enabled = var.auto_deployments_enabled

    image_repository {
      image_identifier      = var.image_identifier
      image_repository_type = "ECR"

      image_configuration {
        port = tostring(var.container_port)

        # ✅ These are MAP attributes, not nested blocks
        runtime_environment_variables = var.env
        runtime_environment_secrets   = var.secret_env
      }
    }
  }

  instance_configuration {
    cpu               = var.cpu
    memory            = var.memory
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = var.health_check_path
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }
}
