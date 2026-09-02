# ==============================================================================
# VPC Module Outputs
# ==============================================================================


# ------------------------------------------------------------------------------
# VPC Outputs
# ------------------------------------------------------------------------------

output "network_id" {
  description = "Fully qualified ID of the VPC network."

  value = google_compute_network.vpc.id
}


output "network_name" {
  description = "Name of the VPC network."

  value = google_compute_network.vpc.name
}


output "network_self_link" {
  description = "Self-link of the VPC network."

  value = google_compute_network.vpc.self_link
}


# ------------------------------------------------------------------------------
# Primary Subnet Outputs
# ------------------------------------------------------------------------------

output "primary_subnet_id" {
  description = "ID of the primary subnet."

  value = google_compute_subnetwork.primary_subnet.id
}


output "primary_subnet_name" {
  description = "Name of the primary subnet."

  value = google_compute_subnetwork.primary_subnet.name
}


output "primary_subnet_self_link" {
  description = "Self-link of the primary subnet."

  value = google_compute_subnetwork.primary_subnet.self_link
}


output "primary_subnet_region" {
  description = "Region of the primary subnet."

  value = google_compute_subnetwork.primary_subnet.region
}


# ------------------------------------------------------------------------------
# Secondary Subnet Outputs
# ------------------------------------------------------------------------------

output "secondary_subnet_id" {
  description = "ID of the secondary subnet, if created."

  value = try(google_compute_subnetwork.secondary_subnet[0].id, null)
}


output "secondary_subnet_name" {
  description = "Name of the secondary subnet, if created."

  value = try(google_compute_subnetwork.secondary_subnet[0].name, null)
}


output "secondary_subnet_self_link" {
  description = "Self-link of the secondary subnet, if created."

  value = try(google_compute_subnetwork.secondary_subnet[0].self_link, null)
}


output "secondary_subnet_region" {
  description = "Region of the secondary subnet, if created."

  value = try(google_compute_subnetwork.secondary_subnet[0].region, null)
}


# ------------------------------------------------------------------------------
# Cloud Router Outputs
# ------------------------------------------------------------------------------

output "nat_router_id" {
  description = "ID of the primary Cloud Router, if Cloud NAT is enabled."

  value = try(google_compute_router.nat_router[0].id, null)
}


output "nat_router_name" {
  description = "Name of the primary Cloud Router, if Cloud NAT is enabled."

  value = try(google_compute_router.nat_router[0].name, null)
}


output "nat_router_self_link" {
  description = "Self-link of the primary Cloud Router, if Cloud NAT is enabled."

  value = try(google_compute_router.nat_router[0].self_link, null)
}


# ------------------------------------------------------------------------------
# Cloud NAT Outputs
# ------------------------------------------------------------------------------

output "cloud_nat_id" {
  description = "ID of the primary Cloud NAT, if enabled."

  value = try(google_compute_router_nat.cloud_nat[0].id, null)
}


output "cloud_nat_name" {
  description = "Name of the primary Cloud NAT, if enabled."

  value = try(google_compute_router_nat.cloud_nat[0].name, null)
}


# ------------------------------------------------------------------------------
# Secondary Cloud Router Outputs
# ------------------------------------------------------------------------------

output "secondary_nat_router_id" {
  description = "ID of the secondary Cloud Router, if created."

  value = try(google_compute_router.secondary_nat_router[0].id, null)
}


output "secondary_nat_router_name" {
  description = "Name of the secondary Cloud Router, if created."

  value = try(google_compute_router.secondary_nat_router[0].name, null)
}


output "secondary_nat_router_self_link" {
  description = "Self-link of the secondary Cloud Router, if created."

  value = try(google_compute_router.secondary_nat_router[0].self_link, null)
}


# ------------------------------------------------------------------------------
# Secondary Cloud NAT Outputs
# ------------------------------------------------------------------------------

output "secondary_cloud_nat_id" {
  description = "ID of the secondary Cloud NAT, if created."

  value = try(google_compute_router_nat.secondary_cloud_nat[0].id, null)
}


output "secondary_cloud_nat_name" {
  description = "Name of the secondary Cloud NAT, if created."

  value = try(google_compute_router_nat.secondary_cloud_nat[0].name, null)
}