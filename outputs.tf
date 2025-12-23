output "service_arn" {
  value = aws_apprunner_service.this.arn
}

output "service_url" {
  value = aws_apprunner_service.this.service_url
}

output "access_role_arn" {
  value = aws_iam_role.apprunner_access_role.arn
}

output "instance_role_arn" {
  value = aws_iam_role.apprunner_instance_role.arn
}
