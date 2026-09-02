variable "project_id" {
  description = "The GCP project ID where the HA-VPN will be deployed."
  type        = string
}

variable "region" {
  description = "The GCP region for the HA-VPN gateway and Cloud Router."
  type        = string
}

variable "network" {
  description = "The name or self-link of the VPC network."
  type        = string
}

variable "vpn_gateway_name" {
  description = "The name of the Cloud HA-VPN gateway."
  type        = string
}

variable "router_name" {
  description = "The name of the Cloud Router."
  type        = string
}

variable "router_asn" {
  description = "The BGP ASN of the Cloud Router (e.g. 64514 or private 64512-65534, 4200000000-4294967294)."
  type        = number
  default     = 65001
}

variable "peer_external_gateway" {
  description = "Configuration for the peer on-premises or cross-cloud VPN gateway."
  type = object({
    name            = string
    redundancy_type = optional(string, "TWO_IPS_REDUNDANCY") # SINGLE_IP_INTERNALLY_REDUNDANT, TWO_IPS_REDUNDANCY, FOUR_IPS_REDUNDANCY
    interfaces = list(object({
      id         = number
      ip_address = string
    }))
  })
}

variable "tunnels" {
  description = "Map of VPN tunnels to establish (typically 2 for HA 99.99% SLA)."
  type = map(object({
    vpn_gateway_interface    = number # 0 or 1
    peer_external_gateway_interface = optional(number, 0)
    shared_secret            = string
    router_interface_ip      = string # BGP Link-local IP e.g. 169.254.0.1/30
    bgp_peer = object({
      name                      = string
      peer_asn                  = number
      peer_ip_address           = string # e.g. 169.254.0.2
      advertised_route_priority = optional(number, 100)
    })
  }))
}
