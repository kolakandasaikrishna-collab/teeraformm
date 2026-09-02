output "custom_rule_names" {
  description = "List of created custom firewall rule names."
  value       = [for r in google_compute_firewall.custom_rules : r.name]
}

output "custom_rules" {
  description = "Map of created custom firewall rules."
  value       = { for k, r in google_compute_firewall.custom_rules : k => r.id }
}

output "default_deny_rule_id" {
  description = "ID of default deny-all ingress rule if created."
  value       = length(google_compute_firewall.default_deny_all_ingress) > 0 ? google_compute_firewall.default_deny_all_ingress[0].id : null
}
