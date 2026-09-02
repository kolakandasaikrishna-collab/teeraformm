variable "project_id" {
  description = "The GCP project ID where Cloud DNS is managed."
  type        = string
}

variable "managed_zones" {
  description = "Map of Cloud DNS managed zones to create."
  type = map(object({
    dns_name        = string
    description     = optional(string, "Managed Zone created by Terraform")
    visibility      = optional(string, "private") # private or public
    labels          = optional(map(string), {})
    private_visibility_config = optional(object({
      networks = list(string)
    }), null)
    forwarding_config = optional(object({
      target_name_servers = list(string)
    }), null)
    peering_config = optional(object({
      target_network = string
    }), null)
  }))
  default = {}
}

variable "record_sets" {
  description = "Map of DNS record sets to create across managed zones."
  type = map(object({
    zone_key = string
    name     = string
    type     = string
    ttl      = optional(number, 300)
    rrdatas  = list(string)
  }))
  default = {}
}

variable "enable_logging_policy" {
  description = "Whether to create a DNS policy enabling query logging on specific VPCs."
  type        = bool
  default     = false
}

variable "dns_policy_networks" {
  description = "List of VPC network self-links to attach the DNS policy to."
  type        = list(string)
  default     = []
}
