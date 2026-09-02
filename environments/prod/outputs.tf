output "network_hub_project_id" {
  description = "Project ID of Central Networking Hub project."
  value       = module.network_hub_project.project_id
}

output "ai_project_id" {
  description = "Project ID of AI Services & GPU Platform project."
  value       = module.ai_project.project_id
}

output "dwh_project_id" {
  description = "Project ID of DWH Data Lake project."
  value       = module.dwh_project.project_id
}

output "biu_project_id" {
  description = "Project ID of BIU CKYC project."
  value       = module.biu_project.project_id
}

output "app_project_id" {
  description = "Project ID of Core Application project."
  value       = module.app_project.project_id
}

output "ncc_star_hub_id" {
  description = "ID of Central Network Connectivity Center Star Hub."
  value       = module.ncc_hub.hub_id
}

output "aws_hybrid_vpn_gateway_id" {
  description = "ID of Cloud HA-VPN Gateway connected to AWS Transit Gateway."
  value       = module.aws_hybrid_vpn.vpn_gateway_id
}

output "psc_google_apis_ip" {
  description = "Internal IP address for Google APIs Private Service Connect endpoint."
  value       = module.psc_google_apis.google_apis_psc_ip
}

output "central_audit_log_bucket" {
  description = "Immutable GCS audit log archive bucket name."
  value       = module.central_logging.storage_bucket_name
}
