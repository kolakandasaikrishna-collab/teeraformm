output "vpn_gateway_id" {
  description = "The ID of the HA-VPN gateway."
  value       = google_compute_ha_vpn_gateway.ha_gateway.id
}

output "vpn_gateway_self_link" {
  description = "The URI of the created HA-VPN gateway."
  value       = google_compute_ha_vpn_gateway.ha_gateway.self_link
}

output "external_gateway_id" {
  description = "The ID of the peer External VPN gateway."
  value       = google_compute_external_vpn_gateway.external_gateway.id
}

output "router_id" {
  description = "The ID of the Cloud Router."
  value       = google_compute_router.router.id
}

output "tunnel_ids" {
  description = "Map of created VPN Tunnel IDs."
  value       = { for k, t in google_compute_vpn_tunnel.tunnels : k => t.id }
}

output "tunnel_self_links" {
  description = "Map of created VPN Tunnel self-links."
  value       = { for k, t in google_compute_vpn_tunnel.tunnels : k => t.self_link }
}
