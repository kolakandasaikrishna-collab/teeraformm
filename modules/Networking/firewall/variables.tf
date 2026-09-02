variable "project_id" {
  description = "The GCP project ID where firewall rules are configured."
  type        = string
}

variable "network_name" {
  description = "The VPC network name to attach firewall rules to."
  type        = string
}

variable "enable_default_deny_all_ingress" {
  description = "Whether to create a low-priority (65534) default-deny-all ingress rule."
  type        = bool
  default     = true
}

variable "enable_allow_health_checks" {
  description = "Whether to allow GCP load balancer health checks (35.191.0.0/16, 130.211.0.0/22)."
  type        = bool
  default     = true
}

variable "enable_allow_iap_ssh_rdp" {
  description = "Whether to allow Identity-Aware Proxy (IAP) bastion access (35.235.240.0/20) on ports 22 and 3389."
  type        = bool
  default     = true
}

variable "custom_rules" {
  description = "Map of custom firewall rules to create on the network."
  type = map(object({
    description          = optional(string, "Custom firewall rule managed by Terraform")
    direction            = optional(string, "INGRESS")
    priority             = optional(number, 1000)
    ranges               = optional(list(string), [])
    source_tags          = optional(list(string), [])
    target_tags          = optional(list(string), [])
    target_service_accounts = optional(list(string), [])
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    enable_logging = optional(bool, true)
  }))
  default = {}
}
