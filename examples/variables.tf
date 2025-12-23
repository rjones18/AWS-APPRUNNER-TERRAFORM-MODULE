variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "ecr_image_uri" {
  description = "Full ECR image URI with tag"
  type        = string
}

variable "secrets_manager_arn" {
  description = "Secrets Manager ARN containing Malik secrets"
  type        = string
}
