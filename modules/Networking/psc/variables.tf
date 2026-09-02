variable "project_id" {
  description = "The GCP project ID where PSC resources are provisioned."
  type        = string
}

variable "network_id" {
  description = "The self-link or ID of the VPC network."
  type        = string
}

variable "enable_google_apis_psc" {
  description = "Whether to create a global Private Service Connect endpoint for Google APIs."
  type        = bool
  default     = true
}

variable "google_apis_ip_address" {
  description = "The internal IP address for the Google APIs PSC endpoint (e.g., 100.100.100.100 or private RFC1918)."
  type        = string
  default     = "10.0.254.254"
}

variable "google_apis_endpoint_name" {
  description = "The name of the Google APIs PSC forwarding rule."
  type        = string
  default     = "psc-google-apis"
}

variable "service_attachments" {
  description = "Map of producer service attachments to publish services."
  type = map(object({
    region                  = string
    nat_subnets             = list(string)
    target_service          = string
    connection_preference   = optional(string, "ACCEPT_MANUAL") # ACCEPT_AUTOMATIC or ACCEPT_MANUAL
    consumer_accept_list    = optional(list(object({
      project_id_or_num = string
      connection_limit  = number
    })), [])
  }))
  default = {}
}

variable "consumer_endpoints" {
  description = "Map of consumer PSC endpoints connecting to producer service attachments."
  type = map(object({
    region             = string
    subnet_id          = string
    ip_address         = optional(string, null)
    target_attachment  = string
  }))
  default = {}
}
