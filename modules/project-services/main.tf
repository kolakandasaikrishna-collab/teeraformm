resource "google_project_service" "services" {
  for_each                   = toset(var.services)
  project                    = var.project_id
  service                    = each.key
  disable_on_destroy         = var.disable_on_destroy
  disable_dependent_services = var.disable_dependent_services
}
