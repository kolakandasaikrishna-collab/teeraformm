output "notification_channel_ids" {
  description = "Map of notification channel keys to their resource IDs."
  value       = { for k, c in google_monitoring_notification_channel.channels : k => c.id }
}

output "notification_channel_names" {
  description = "Map of notification channel keys to their full resource names."
  value       = { for k, c in google_monitoring_notification_channel.channels : k => c.name }
}

output "alert_policy_ids" {
  description = "Map of alert policy keys to their resource IDs."
  value       = { for k, p in google_monitoring_alert_policy.alert_policies : k => p.id }
}

output "dashboard_ids" {
  description = "Map of dashboard keys to their IDs."
  value       = { for k, d in google_monitoring_dashboard.dashboards : k => d.id }
}
