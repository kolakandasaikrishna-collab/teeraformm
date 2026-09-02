# Centralized Cloud Storage Log Bucket
resource "google_storage_bucket" "log_bucket" {
  count                       = var.create_storage_bucket ? 1 : 0
  project                     = var.project_id
  name                        = var.storage_bucket_name != null ? var.storage_bucket_name : "${var.project_id}-central-logs"
  location                    = var.location
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.log_retention_days
    }
    action {
      type = "Delete"
    }
  }

  dynamic "encryption" {
    for_each = var.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = var.kms_key_name
    }
  }
}

# Centralized BigQuery Dataset for SIEM & Audit Analytics
resource "google_bigquery_dataset" "log_dataset" {
  count                   = var.create_bigquery_dataset ? 1 : 0
  project                 = var.project_id
  dataset_id              = var.bigquery_dataset_id
  friendly_name           = "Centralized Audit Logs"
  description             = "Central audit and security log sink dataset managed by Terraform"
  location                = var.location
  delete_contents_on_destroy = false

  default_table_expiration_ms = var.log_retention_days * 86400000
}

# Project-Level Log Sinks
resource "google_logging_project_sink" "project_sinks" {
  for_each               = var.project_sinks
  project                = var.project_id
  name                   = each.key
  destination            = each.value.destination
  filter                 = each.value.filter
  unique_writer_identity = each.value.unique_writer_identity
  disabled               = each.value.disabled

  dynamic "exclusions" {
    for_each = each.value.exclusions
    content {
      name        = exclusions.key
      filter      = exclusions.value.filter
      description = exclusions.value.description
    }
  }
}

# Organization-Level Log Sinks
resource "google_logging_organization_sink" "org_sinks" {
  for_each         = var.org_id != null ? var.org_sinks : {}
  org_id           = var.org_id
  name             = each.key
  destination      = each.value.destination
  filter           = each.value.filter
  include_children = each.value.include_children
  disabled         = each.value.disabled
}

# Grant Writer Identity Permissions to Storage Bucket
resource "google_storage_bucket_iam_member" "sink_storage_writer" {
  for_each = {
    for k, s in google_logging_project_sink.project_sinks : k => s
    if var.create_storage_bucket && length(regexall("storage.googleapis.com", s.destination)) > 0
  }
  bucket = google_storage_bucket.log_bucket[0].name
  role   = "roles/storage.objectCreator"
  member = each.value.writer_identity
}

# Grant Writer Identity Permissions to BigQuery Dataset
resource "google_bigquery_dataset_access" "sink_bigquery_writer" {
  for_each = {
    for k, s in google_logging_project_sink.project_sinks : k => s
    if var.create_bigquery_dataset && length(regexall("bigquery.googleapis.com", s.destination)) > 0
  }
  project       = var.project_id
  dataset_id    = google_bigquery_dataset.log_dataset[0].dataset_id
  role          = "roles/bigquery.dataEditor"
  user_by_email = replace(each.value.writer_identity, "serviceAccount:", "")
}
