variable "environment" {
  description = "The deployment environment name."
  type        = string
  default     = "prd"
}

variable "org_id" {
  description = "The numeric GCP Organization ID."
  type        = string
}

variable "billing_account_id" {
  description = "The alpha-numeric Billing Account ID."
  type        = string
}

variable "platform_folder_id" {
  description = "The Folder ID for central Platform projects (network-hub-prd, security-prd, etc.)."
  type        = string
  default     = null
}

variable "prod_folder_id" {
  description = "The Folder ID for Production business workloads (DWH, BIU, App, AI Platform)."
  type        = string
  default     = null
}

variable "primary_region" {
  description = "Primary GCP Region for production workloads (e.g., us-central1 or asia-south1)."
  type        = string
  default     = "us-central1"
}

variable "secondary_region" {
  description = "Secondary GCP Region for failover/pilot light DR (e.g., us-east4 or asia-south2)."
  type        = string
  default     = "us-east4"
}

variable "alert_notification_email" {
  description = "Production alert email distribution list."
  type        = string
  default     = "gcp-secops-alerts@example.com"
}

variable "aws_tgw_asn" {
  description = "Autonomous System Number (ASN) for AWS Transit Gateway BGP peering."
  type        = number
  default     = 64512
}

variable "aws_tgw_ip_addresses" {
  description = "List of public IP addresses for the AWS Transit Gateway VPN endpoints."
  type        = list(string)
  default     = ["52.0.10.1", "52.0.10.2"]
}
