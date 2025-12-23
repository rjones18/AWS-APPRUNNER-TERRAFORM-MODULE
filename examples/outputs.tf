output "malik_service_url" {
  description = "Public URL for Malik AI"
  value       = module.malik_apprunner.service_url
}

output "malik_service_arn" {
  value = module.malik_apprunner.service_arn
}
