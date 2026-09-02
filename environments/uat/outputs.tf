output "hub_project_id" {
  description = "Project ID of Hub Networking project."
  value       = module.hub_project.project_id
}

output "app_project_id" {
  description = "Project ID of Application Spoke project."
  value       = module.app_project.project_id
}

output "security_logging_project_id" {
  description = "Project ID of Security & Central Logging project."
  value       = module.security_logging_project.project_id
}

output "ncc_hub_id" {
  description = "ID of the Network Connectivity Center Hub."
  value       = module.ncc.hub_id
}

output "ha_vpn_gateway_id" {
  description = "ID of HA-VPN Gateway."
  value       = module.ha_vpn.vpn_gateway_id
}

output "psc_google_apis_ip" {
  description = "IP address of Google APIs Private Service Connect endpoint."
  value       = module.psc.google_apis_psc_ip
}

output "central_log_bucket" {
  description = "Name of central log GCS bucket."
  value       = module.central_logging.storage_bucket_name
}

output "bigquery_dataset_id" {
  description = "ID of BigQuery security log dataset."
  value       = module.central_logging.bigquery_dataset_id
}
