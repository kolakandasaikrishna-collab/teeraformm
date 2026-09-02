variable "org_id" {
  description = "The numeric GCP Organization ID."
  type        = string
}

variable "billing_account_id" {
  description = "The alpha-numeric Billing Account ID to link new projects to."
  type        = string
}

variable "parent_folder_id" {
  description = "Optional Folder ID under which landing zone platform resources will be deployed."
  type        = string
  default     = null
}

variable "default_region" {
  description = "The default GCP region for state buckets and KMS keys (e.g. us-central1 or asia-south1)."
  type        = string
  default     = "us-central1"
}

variable "bootstrap_project_id" {
  description = "The project ID for the bootstrap/automation project."
  type        = string
  default     = "tf-state-prd"
}

variable "state_bucket_prefix" {
  description = "Prefix for Terraform state GCS bucket names."
  type        = string
  default     = "tf-state-enterprise"
}

variable "enable_state_cmek" {
  description = "Whether to encrypt state buckets with a Customer-Managed Encryption Key (CMEK)."
  type        = bool
  default     = true
}
