output "google_apis_psc_ip" {
  description = "IP address reserved for Google APIs PSC endpoint."
  value       = length(google_compute_global_address.psc_google_apis) > 0 ? google_compute_global_address.psc_google_apis[0].address : null
}

output "google_apis_forwarding_rule_id" {
  description = "ID of the Google APIs forwarding rule."
  value       = length(google_compute_global_forwarding_rule.psc_google_apis) > 0 ? google_compute_global_forwarding_rule.psc_google_apis[0].id : null
}

output "service_attachment_ids" {
  description = "Map of published service attachment IDs."
  value       = { for k, s in google_compute_service_attachment.service_attachments : k => s.id }
}

output "consumer_forwarding_rule_ids" {
  description = "Map of consumer forwarding rule IDs."
  value       = { for k, f in google_compute_forwarding_rule.consumer_forwarding_rules : k => f.id }
}
