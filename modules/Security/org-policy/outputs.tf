output "boolean_policy_names" {
  description = "List of created boolean org policy resource names."
  value       = [for p in google_org_policy_policy.boolean_policies : p.name]
}

output "list_policy_names" {
  description = "List of created list org policy resource names."
  value       = [for p in google_org_policy_policy.list_policies : p.name]
}
