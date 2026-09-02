resource "random_id" "project_suffix" {
  count       = var.random_project_id ? 1 : 0
  byte_length = 3
}

locals {
  project_id = var.random_project_id ? "${var.project_id}-${random_id.project_suffix[0].hex}" : var.project_id
}

resource "google_project" "project" {
  name                = var.name
  project_id          = local.project_id
  org_id              = var.folder_id == null ? var.org_id : null
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = var.auto_create_network
  labels              = var.labels
  deletion_policy     = var.deletion_policy
}
