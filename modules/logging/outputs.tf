output "storage_bucket_name" {
  description = "Name of the centralized log storage bucket."
  value       = length(google_storage_bucket.log_bucket) > 0 ? google_storage_bucket.log_bucket[0].name : null
}

output "storage_bucket_url" {
  description = "URL of the centralized log storage bucket."
  value       = length(google_storage_bucket.log_bucket) > 0 ? google_storage_bucket.log_bucket[0].url : null
}

output "bigquery_dataset_id" {
  description = "ID of the BigQuery audit log dataset."
  value       = length(google_bigquery_dataset.log_dataset) > 0 ? google_bigquery_dataset.log_dataset[0].dataset_id : null
}

output "project_sink_writer_identities" {
  description = "Map of project sinks to their writer identities (service accounts)."
  value       = { for k, s in google_logging_project_sink.project_sinks : k => s.writer_identity }
}

output "org_sink_writer_identities" {
  description = "Map of org sinks to their writer identities."
  value       = { for k, s in google_logging_organization_sink.org_sinks : k => s.writer_identity }
}
