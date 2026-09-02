resource "google_network_connectivity_hub" "hub" {
  project     = var.project_id
  name        = var.hub_name
  description = var.hub_description
  labels      = var.labels
}

# VPC Network Spokes (Global)
resource "google_network_connectivity_spoke" "vpc_spokes" {
  for_each    = var.vpc_spokes
  project     = var.project_id
  name        = each.key
  location    = "global"
  description = each.value.description
  hub         = google_network_connectivity_hub.hub.id
  labels      = var.labels

  linked_vpc_network {
    uri                   = each.value.vpc_network_uri
    exclude_export_ranges = each.value.exclude_export_ranges
  }
}

# VPN Tunnel Spokes (Regional)
resource "google_network_connectivity_spoke" "vpn_spokes" {
  for_each    = var.vpn_spokes
  project     = var.project_id
  name        = each.key
  location    = each.value.location
  description = each.value.description
  hub         = google_network_connectivity_hub.hub.id
  labels      = var.labels

  linked_vpn_tunnels {
    uris                       = each.value.vpn_tunnel_uris
    site_to_site_data_transfer = each.value.site_to_site_data_transfer
  }
}

# Router Appliance Spokes (Regional)
resource "google_network_connectivity_spoke" "router_appliance_spokes" {
  for_each    = var.router_appliance_spokes
  project     = var.project_id
  name        = each.key
  location    = each.value.location
  description = each.value.description
  hub         = google_network_connectivity_hub.hub.id
  labels      = var.labels

  linked_router_appliance_instances {
    site_to_site_data_transfer = each.value.site_to_site_data_transfer

    dynamic "instances" {
      for_each = each.value.instances
      content {
        virtual_machine = instances.value.virtual_machine
        ip_address      = instances.value.ip_address
      }
    }
  }
}
