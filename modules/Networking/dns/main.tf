# Managed Zones
resource "google_dns_managed_zone" "zones" {
  for_each    = var.managed_zones
  project     = var.project_id
  name        = each.key
  dns_name    = each.value.dns_name
  description = each.value.description
  visibility  = each.value.visibility
  labels      = each.value.labels

  dynamic "private_visibility_config" {
    for_each = each.value.private_visibility_config != null ? [each.value.private_visibility_config] : []
    content {
      dynamic "networks" {
        for_each = private_visibility_config.value.networks
        content {
          network_url = networks.value
        }
      }
    }
  }

  dynamic "forwarding_config" {
    for_each = each.value.forwarding_config != null ? [each.value.forwarding_config] : []
    content {
      dynamic "target_name_servers" {
        for_each = forwarding_config.value.target_name_servers
        content {
          ipv4_address = target_name_servers.value
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = each.value.peering_config != null ? [each.value.peering_config] : []
    content {
      target_network {
        network_url = peering_config.value.target_network
      }
    }
  }
}

# DNS Record Sets
resource "google_dns_record_set" "records" {
  for_each     = var.record_sets
  project      = var.project_id
  managed_zone = google_dns_managed_zone.zones[each.value.zone_key].name
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
}

# DNS Query Logging Policy
resource "google_dns_policy" "logging_policy" {
  count                     = var.enable_logging_policy ? 1 : 0
  project                   = var.project_id
  name                      = "${var.project_id}-dns-logging-policy"
  enable_inbound_forwarding = false
  enable_logging            = true

  dynamic "networks" {
    for_each = var.dns_policy_networks
    content {
      network_url = networks.value
    }
  }
}
