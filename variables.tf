variable "name" {
  description = "App Runner service name"
  type        = string
}

variable "region" {
  description = "AWS region (used in role policy conditions sometimes). Optional."
  type        = string
  default     = null
}

variable "image_identifier" {
  description = "ECR image URI (e.g., 123.dkr.ecr.us-east-1.amazonaws.com/repo:tag)"
  type        = string
}

variable "container_port" {
  description = "Container port App Runner routes to"
  type        = number
  default     = 5001
}

variable "cpu" {
  description = "CPU units: 1024 (1 vCPU) or 2048 (2 vCPU)"
  type        = string
  default     = "1024"
}

variable "memory" {
  description = "Memory: 2048 (2GB) or 3072 (3GB) or 4096 (4GB)"
  type        = string
  default     = "2048"
}

variable "auto_deployments_enabled" {
  description = "Automatically deploy when new image is pushed"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "HTTP path for health checks"
  type        = string
  default     = "/"
}

variable "env" {
  description = "Plain environment variables"
  type        = map(string)
  default     = {}
}

variable "secret_env" {
  description = <<EOT
Map of ENV_VAR_NAME => Secrets Manager secret ARN or Parameter Store ARN
(App Runner will inject it as an environment variable)
EOT
  type        = map(string)
  default     = {}
}

variable "secretsmanager_arns" {
  description = "List of Secrets Manager ARNs the app needs to read (runtime IAM permissions)"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
