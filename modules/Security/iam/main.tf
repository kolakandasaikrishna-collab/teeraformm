# Service Accounts Creation
resource "google_service_account" "accounts" {
  for_each     = var.service_accounts
  project      = var.project_id
  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
}

# Project Custom Roles
resource "google_project_iam_custom_role" "custom_roles" {
  for_each    = var.custom_roles
  project     = var.project_id
  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}

# Flatten Project IAM Members (additive, non-destructive)
locals {
  project_iam_members = flatten([
    for role, members in var.project_bindings : [
      for member in members : {
        role   = role
        member = member
        key    = "${role}-${member}"
      }
    ]
  ])

  folder_iam_members = flatten([
    for role, members in var.folder_bindings : [
      for member in members : {
        role   = role
        member = member
        key    = "${role}-${member}"
      }
    ]
  ])

  org_iam_members = flatten([
    for role, members in var.org_bindings : [
      for member in members : {
        role   = role
        member = member
        key    = "${role}-${member}"
      }
    ]
  ])
}

resource "google_project_iam_member" "project_members" {
  for_each = { for item in local.project_iam_members : item.key => item if var.project_id != null }
  project  = var.project_id
  role     = each.value.role
  member   = each.value.member
}

resource "google_folder_iam_member" "folder_members" {
  for_each = { for item in local.folder_iam_members : item.key => item if var.folder_id != null }
  folder   = var.folder_id
  role     = each.value.role
  member   = each.value.member
}

resource "google_organization_iam_member" "org_members" {
  for_each = { for item in local.org_iam_members : item.key => item if var.org_id != null }
  org_id   = var.org_id
  role     = each.value.role
  member   = each.value.member
}
