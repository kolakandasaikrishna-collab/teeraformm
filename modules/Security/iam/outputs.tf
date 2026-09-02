output "service_accounts" {
  description = "Map of created service accounts with email and unique_id."
  value = {
    for k, sa in google_service_account.accounts : k => {
      email     = sa.email
      unique_id = sa.unique_id
      name      = sa.name
    }
  }
}

output "service_account_emails" {
  description = "Map of service account keys to their email addresses."
  value       = { for k, sa in google_service_account.accounts : k => sa.email }
}

output "custom_roles" {
  description = "Map of created custom roles."
  value = {
    for k, r in google_project_iam_custom_role.custom_roles : k => {
      id    = r.id
      title = r.title
    }
  }
}
