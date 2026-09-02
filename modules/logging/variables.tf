variable "project_id" {
  description = "The GCP project ID where log storage destinations (GCS, BigQuery) will reside."
  type        = string
}

variable "location" {
  description = "The GCP region/location for log storage buckets and BigQuery datasets."
  type        = string
  default     = "us-central1"
}

variable "create_storage_bucket" {
  description = "Whether to create a centralized Cloud Storage bucket for cold log archive."
  type        = bool
  default     = true
}

variable "storage_bucket_name" {
  description = "Name of the GCS log storage bucket (must be globally unique)."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Retention period in days before logs are deleted or transitioned in GCS."
  type        = number
  default     = 365
}

variable "kms_key_name" {
  description = "Optional KMS Crypto Key ID for CMEK encryption on the log bucket."
  type        = string
  default     = null
}

variable "create_bigquery_dataset" {
  description = "Whether to create a BigQuery dataset for security analytics log exports."
  type        = bool
  default     = true
}

variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID for log storage."
  type        = string
  default     = "central_audit_logs"
}

variable "project_sinks" {
  description = "Map of project-level log sinks to create."
  type = map(object({
    destination            = string # e.g. storage.googleapis.com/<bucket> or bigquery.googleapis.com/projects/...
    filter                 = string
    unique_writer_identity = optional(bool, true)
    disabled               = optional(bool, false)
    exclusions = optional(map(object({
      filter      = string
      description = optional(string, "")
    })), {})
  }))
  default = {}
}

variable "org_id" {
  description = "Optional Organization ID for aggregated organization-level log sinks."
  type        = string
  default     = null
}

variable "org_sinks" {
  description = "Map of org-level log sinks to create."
  type = map(object({
    destination      = string
    filter           = string
    include_children = optional(bool, true)
    disabled         = optional(bool, false)
  }))
  default = {}
}
