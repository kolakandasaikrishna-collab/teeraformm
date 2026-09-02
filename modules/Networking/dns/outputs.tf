output "zone_names" {
  description = "List of created managed zone names."
  value       = [for z in google_dns_managed_zone.zones : z.name]
}

output "zone_name_servers" {
  description = "Map of managed zone names to their designated name servers."
  value       = { for k, z in google_dns_managed_zone.zones : k => z.name_servers }
}

output "zone_ids" {
  description = "Map of managed zone keys to their resource IDs."
  value       = { for k, z in google_dns_managed_zone.zones : k => z.id }
}

output "policy_id" {
  description = "The ID of the DNS logging policy if enabled."
  value       = length(google_dns_policy.logging_policy) > 0 ? google_dns_policy.logging_policy[0].id : null
}
