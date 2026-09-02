output "project_id" {
  description = "The GCP project ID where services were enabled."
  value       = var.project_id
}

output "enabled_services" {
  description = "List of services that were enabled."
  value       = [for s in google_project_service.services : s.service]
}
