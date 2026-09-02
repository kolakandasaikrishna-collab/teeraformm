# PSC Endpoint for Google APIs (Global)
resource "google_compute_global_address" "psc_google_apis" {
  count        = var.enable_google_apis_psc ? 1 : 0
  project      = var.project_id
  name         = "${var.google_apis_endpoint_name}-ip"
  address_type = "INTERNAL"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = var.network_id
  address      = var.google_apis_ip_address
}

resource "google_compute_global_forwarding_rule" "psc_google_apis" {
  count                 = var.enable_google_apis_psc ? 1 : 0
  project               = var.project_id
  name                  = var.google_apis_endpoint_name
  target                = "all-apis"
  network               = var.network_id
  ip_address            = google_compute_global_address.psc_google_apis[0].id
  load_balancing_scheme = ""
}

# Service Attachments (Publishing Producer Services)
resource "google_compute_service_attachment" "service_attachments" {
  for_each              = var.service_attachments
  project               = var.project_id
  name                  = each.key
  region                = each.value.region
  description           = "PSC Service Attachment managed by Terraform"
  enable_proxy_protocol = false
  connection_preference = each.value.connection_preference
  nat_subnets           = each.value.nat_subnets
  target_service        = each.value.target_service

  dynamic "consumer_accept_lists" {
    for_each = each.value.consumer_accept_list
    content {
      project_id_or_num = consumer_accept_lists.value.project_id_or_num
      connection_limit  = consumer_accept_lists.value.connection_limit
    }
  }
}

# Consumer PSC Endpoints (Connecting to Producer Attachments)
resource "google_compute_address" "consumer_addresses" {
  for_each     = var.consumer_endpoints
  project      = var.project_id
  name         = "${each.key}-ip"
  region       = each.value.region
  subnetwork   = each.value.subnet_id
  address_type = "INTERNAL"
  address      = each.value.ip_address
}

resource "google_compute_forwarding_rule" "consumer_forwarding_rules" {
  for_each              = var.consumer_endpoints
  project               = var.project_id
  name                  = each.key
  region                = each.value.region
  network               = var.network_id
  subnetwork            = each.value.subnet_id
  ip_address            = google_compute_address.consumer_addresses[each.key].id
  target                = each.value.target_attachment
  load_balancing_scheme = ""
}
