variable "environment" {
  description = "The deployment environment name."
  type        = string
  default     = "uat"
}

variable "org_id" {
  description = "The numeric GCP Organization ID."
  type        = string
}

variable "billing_account_id" {
  description = "The alpha-numeric Billing Account ID."
  type        = string
}

variable "nonprod_folder_id" {
  description = "The Folder ID for NonProd / UAT workloads."
  type        = string
  default     = null
}

variable "sandbox_folder_id" {
  description = "The Folder ID for decoupled Sandbox experimentation projects."
  type        = string
  default     = null
}

variable "default_region" {
  description = "Default GCP Region (e.g., us-central1 or asia-south1)."
  type        = string
  default     = "us-central1"
}

variable "alert_notification_email" {
  description = "Email address for monitoring alert notifications."
  type        = string
  default     = "gcp-nonprod-alerts@example.com"
}
