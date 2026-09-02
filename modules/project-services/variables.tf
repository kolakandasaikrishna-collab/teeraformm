variable "project_id" {
  description = "The GCP project ID where APIs will be enabled."
  type        = string
}

variable "services" {
  description = "List of GCP service APIs to enable on the project."
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
    "networkconnectivity.googleapis.com",
    "dns.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "aiplatform.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com"
  ]
}

variable "disable_on_destroy" {
  description = "Whether to disable the service when the resource is destroyed. Default is false to prevent accidental service disruption."
  type        = bool
  default     = false
}

variable "disable_dependent_services" {
  description = "Whether to disable dependent services when the service is disabled."
  type        = bool
  default     = false
}
