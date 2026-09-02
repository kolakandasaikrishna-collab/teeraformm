# Baseline Rule 1: Default Deny All Ingress
resource "google_compute_firewall" "default_deny_all_ingress" {
  count       = var.enable_default_deny_all_ingress ? 1 : 0
  name        = "${var.network_name}-deny-all-ingress"
  project     = var.project_id
  network     = var.network_name
  description = "Default deny-all ingress rule"
  direction   = "INGRESS"
  priority    = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Baseline Rule 2: Allow GCP Health Checks (Load Balancer probes)
resource "google_compute_firewall" "allow_health_checks" {
  count       = var.enable_allow_health_checks ? 1 : 0
  name        = "${var.network_name}-allow-health-checks"
  project     = var.project_id
  network     = var.network_name
  description = "Allow Google Cloud Load Balancer health checks"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "8443"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Baseline Rule 3: Allow Identity-Aware Proxy (IAP) SSH / RDP
resource "google_compute_firewall" "allow_iap" {
  count       = var.enable_allow_iap_ssh_rdp ? 1 : 0
  name        = "${var.network_name}-allow-iap-bastion"
  project     = var.project_id
  network     = var.network_name
  description = "Allow Google Cloud Identity-Aware Proxy (IAP) secure bastion access"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["35.235.240.0/20"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Custom Firewall Rules
resource "google_compute_firewall" "custom_rules" {
  for_each                = var.custom_rules
  name                    = "${var.network_name}-${each.key}"
  project                 = var.project_id
  network                 = var.network_name
  description             = each.value.description
  direction               = each.value.direction
  priority                = each.value.priority
  source_ranges           = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges      = each.value.direction == "EGRESS" ? each.value.ranges : null
  source_tags             = length(each.value.source_tags) > 0 ? each.value.source_tags : null
  target_tags             = length(each.value.target_tags) > 0 ? each.value.target_tags : null
  target_service_accounts = length(each.value.target_service_accounts) > 0 ? each.value.target_service_accounts : null

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = length(allow.value.ports) > 0 ? allow.value.ports : null
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = length(deny.value.ports) > 0 ? deny.value.ports : null
    }
  }

  dynamic "log_config" {
    for_each = each.value.enable_logging ? [1] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}
