output "hub_id" {
  description = "The unique identifier of the NCC Hub."
  value       = google_network_connectivity_hub.hub.id
}

output "hub_name" {
  description = "The name of the NCC Hub."
  value       = google_network_connectivity_hub.hub.name
}

output "hub_state" {
  description = "The current state of the NCC Hub."
  value       = google_network_connectivity_hub.hub.state
}

output "vpc_spoke_ids" {
  description = "Map of VPC Spoke IDs."
  value       = { for k, s in google_network_connectivity_spoke.vpc_spokes : k => s.id }
}

output "vpn_spoke_ids" {
  description = "Map of VPN Spoke IDs."
  value       = { for k, s in google_network_connectivity_spoke.vpn_spokes : k => s.id }
}

output "router_appliance_spoke_ids" {
  description = "Map of Router Appliance Spoke IDs."
  value       = { for k, s in google_network_connectivity_spoke.router_appliance_spokes : k => s.id }
}
