variable "project_id" {
  description = "The GCP project ID where NCC resources are created."
  type        = string
}

variable "hub_name" {
  description = "The name of the Network Connectivity Center Hub."
  type        = string
}

variable "hub_description" {
  description = "Description for the NCC Hub."
  type        = string
  default     = "Enterprise NCC Hub managed by Terraform"
}

variable "labels" {
  description = "Labels to assign to the NCC Hub and Spokes."
  type        = map(string)
  default     = {}
}

variable "vpc_spokes" {
  description = "Map of VPC network spokes to attach to the hub."
  type = map(object({
    vpc_network_uri = string
    description     = optional(string, "VPC spoke attached to NCC hub")
    exclude_export_ranges = optional(list(string), [])
  }))
  default = {}
}

variable "vpn_spokes" {
  description = "Map of VPN tunnel spokes to attach to the hub."
  type = map(object({
    location            = string
    vpn_tunnel_uris     = list(string)
    description         = optional(string, "VPN spoke attached to NCC hub")
    site_to_site_data_transfer = optional(bool, true)
  }))
  default = {}
}

variable "router_appliance_spokes" {
  description = "Map of Router Appliance instances spokes."
  type = map(object({
    location                   = string
    instances                  = list(object({
      virtual_machine = string
      ip_address      = string
    }))
    site_to_site_data_transfer = optional(bool, true)
    description                = optional(string, "Router Appliance spoke")
  }))
  default = {}
}
