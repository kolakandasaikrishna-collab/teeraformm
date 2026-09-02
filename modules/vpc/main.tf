# ==============================================================================
# GCP VPC Module
# ==============================================================================
# Creates:
#   - VPC Network
#   - Primary Subnet
#   - Optional Secondary Subnet
#   - Optional GKE Secondary IP Ranges
#   - Optional Cloud Router
#   - Optional Cloud NAT
#   - Optional Secondary Cloud Router/NAT
#
# This module does NOT create GCP APIs.
# Enable required APIs from the root module before calling this module.
# ==============================================================================


# ------------------------------------------------------------------------------
# VPC Network
# ------------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  description             = var.vpc_description
}


# ------------------------------------------------------------------------------
# Primary Subnet
# ------------------------------------------------------------------------------

resource "google_compute_subnetwork" "primary_subnet" {
  name                     = var.primary_subnet_name
  project                  = var.project_id
  region                   = var.primary_region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.primary_subnet_cidr
  private_ip_google_access = var.private_ip_google_access
  description              = var.primary_subnet_description

  # --------------------------------------------------------------------------
  # GKE Secondary IP Ranges
  # --------------------------------------------------------------------------

  dynamic "secondary_ip_range" {
    for_each = var.enable_secondary_ip_ranges ? var.secondary_ip_ranges : []

    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}


# ------------------------------------------------------------------------------
# Secondary Subnet
# ------------------------------------------------------------------------------

resource "google_compute_subnetwork" "secondary_subnet" {
  count = var.enable_secondary_subnet ? 1 : 0

  name                     = var.secondary_subnet_name
  project                  = var.project_id
  region                   = var.secondary_region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.secondary_subnet_cidr
  private_ip_google_access = var.private_ip_google_access
  description              = var.secondary_subnet_description

  # --------------------------------------------------------------------------
  # GKE Secondary IP Ranges
  # --------------------------------------------------------------------------

  dynamic "secondary_ip_range" {
    for_each = var.enable_secondary_ip_ranges ? var.secondary_secondary_ip_ranges : []

    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}


# ------------------------------------------------------------------------------
# Primary Cloud Router
# ------------------------------------------------------------------------------

resource "google_compute_router" "nat_router" {
  count = var.enable_cloud_nat ? 1 : 0

  name        = var.router_name
  project     = var.project_id
  region      = var.primary_region
  network     = google_compute_network.vpc.id
  description = var.router_description
}


# ------------------------------------------------------------------------------
# Primary Cloud NAT
# ------------------------------------------------------------------------------

resource "google_compute_router_nat" "cloud_nat" {
  count = var.enable_cloud_nat ? 1 : 0

  name                               = var.nat_name
  project                            = var.project_id
  router                             = google_compute_router.nat_router[0].name
  region                             = google_compute_router.nat_router[0].region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  nat_ips                            = var.nat_ip_allocate_option == "MANUAL_ONLY" ? var.nat_ips : null
  source_subnetwork_ip_ranges_to_nat = var.nat_source_subnetwork_ip_ranges

  # --------------------------------------------------------------------------
  # NAT Logging
  # --------------------------------------------------------------------------

  dynamic "log_config" {
    for_each = var.enable_nat_logging ? [1] : []

    content {
      enable = true
      filter = var.nat_logging_filter
    }
  }
}


# ------------------------------------------------------------------------------
# Secondary Cloud Router
# ------------------------------------------------------------------------------

resource "google_compute_router" "secondary_nat_router" {
  count = var.enable_cloud_nat && var.enable_secondary_subnet ? 1 : 0

  name        = "${var.router_name}-secondary"
  project     = var.project_id
  region      = var.secondary_region
  network     = google_compute_network.vpc.id
  description = "Secondary region Cloud Router for ${var.vpc_name}"
}


# ------------------------------------------------------------------------------
# Secondary Cloud NAT
# ------------------------------------------------------------------------------

resource "google_compute_router_nat" "secondary_cloud_nat" {
  count = var.enable_cloud_nat && var.enable_secondary_subnet ? 1 : 0

  name                               = "${var.nat_name}-secondary"
  project                            = var.project_id
  router                             = google_compute_router.secondary_nat_router[0].name
  region                             = google_compute_router.secondary_nat_router[0].region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  nat_ips                            = var.nat_ip_allocate_option == "MANUAL_ONLY" ? var.secondary_nat_ips : null
  source_subnetwork_ip_ranges_to_nat = var.nat_source_subnetwork_ip_ranges

  # --------------------------------------------------------------------------
  # NAT Logging
  # --------------------------------------------------------------------------

  dynamic "log_config" {
    for_each = var.enable_nat_logging ? [1] : []

    content {
      enable = true
      filter = var.nat_logging_filter
    }
  }
}