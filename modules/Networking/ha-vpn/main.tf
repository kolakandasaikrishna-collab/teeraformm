# Cloud HA-VPN Gateway (Google side)
resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  name    = var.vpn_gateway_name
  project = var.project_id
  region  = var.region
  network = var.network
}

# External VPN Gateway (Peer side)
resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = var.peer_external_gateway.name
  project         = var.project_id
  redundancy_type = var.peer_external_gateway.redundancy_type
  description     = "Peer external VPN gateway managed by Terraform"

  dynamic "interface" {
    for_each = var.peer_external_gateway.interfaces
    content {
      id         = interface.value.id
      ip_address = interface.value.ip_address
    }
  }
}

# Cloud Router
resource "google_compute_router" "router" {
  name    = var.router_name
  project = var.project_id
  region  = var.region
  network = var.network

  bgp {
    asn = var.router_asn
  }
}

# VPN Tunnels
resource "google_compute_vpn_tunnel" "tunnels" {
  for_each                        = var.tunnels
  name                            = "${var.vpn_gateway_name}-${each.key}"
  project                         = var.project_id
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  shared_secret                   = each.value.shared_secret
  router                          = google_compute_router.router.id
  ike_version                     = 2
}

# Router Interfaces for BGP Peering
resource "google_compute_router_interface" "router_interfaces" {
  for_each   = var.tunnels
  name       = "if-${each.key}"
  project    = var.project_id
  region     = var.region
  router     = google_compute_router.router.name
  ip_range   = each.value.router_interface_ip
  vpn_tunnel = google_compute_vpn_tunnel.tunnels[each.key].name
}

# Router BGP Peers
resource "google_compute_router_peer" "bgp_peers" {
  for_each                  = var.tunnels
  name                      = each.value.bgp_peer.name
  project                   = var.project_id
  region                    = var.region
  router                    = google_compute_router.router.name
  interface                 = google_compute_router_interface.router_interfaces[each.key].name
  peer_asn                  = each.value.bgp_peer.peer_asn
  peer_ip_address           = each.value.bgp_peer.peer_ip_address
  advertised_route_priority = each.value.bgp_peer.advertised_route_priority
}
