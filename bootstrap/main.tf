resource "random_id" "suffix" {
  byte_length = 4
}

# ==============================================================================
# 1. Bootstrap / Automation Project
# ==============================================================================

module "bootstrap_project" {
  source = "../modules/project"

  name                = "Automation & State Management"
  project_id          = var.bootstrap_project_id
  org_id              = var.parent_folder_id == null ? var.org_id : null
  folder_id           = var.parent_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"

  labels = {
    environment = "prd"
    cost-center = "engineering"
    owner       = "cloud-infra-team"
    role        = "automation-tf-state"
  }
}

# ==============================================================================
# 2. Enable Required APIs in Bootstrap / Automation Project
# ==============================================================================

module "bootstrap_services" {
  source = "../modules/project-services"

  project_id = module.bootstrap_project.project_id

  services = [
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "networkconnectivity.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "bigquery.googleapis.com"
  ]

  depends_on = [
    module.bootstrap_project
  ]
}

# ==============================================================================
# 3. Optional KMS Key for Terraform State Encryption
# ==============================================================================

module "state_kms" {
  count  = var.enable_state_cmek ? 1 : 0
  source = "../modules/Security/kms"

  project_id = module.bootstrap_project.project_id
  location   = var.default_region

  keyrings = {
    "tf-state-keyring" = {
      keys = {
        "tf-state-key" = {
          rotation_period = "7776000s"
        }
      }
    }
  }

  depends_on = [
    module.bootstrap_services
  ]
}

# ==============================================================================
# 4. Terraform Remote State Buckets
# ==============================================================================

locals {
  state_buckets = {
    bootstrap = "${var.state_bucket_prefix}-bootstrap-${random_id.suffix.hex}"
    uat       = "${var.state_bucket_prefix}-uat-${random_id.suffix.hex}"
    prod      = "${var.state_bucket_prefix}-prod-${random_id.suffix.hex}"
  }
}

resource "google_storage_bucket" "tf_state" {
  for_each = local.state_buckets

  name                        = each.value
  project                     = module.bootstrap_project.project_id
  location                    = var.default_region
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }

    action {
      type = "Delete"
    }
  }

  dynamic "encryption" {
    for_each = var.enable_state_cmek ? [1] : []

    content {
      default_kms_key_name = module.state_kms[0].crypto_key_ids[
        "tf-state-keyring/tf-state-key"
      ]
    }
  }

  depends_on = [
    module.bootstrap_services,
    module.state_kms
  ]
}

# ==============================================================================
# 5. Terraform Automation Service Account
# ==============================================================================

module "tf_runner_sa" {
  source = "../modules/Security/iam"

  project_id = module.bootstrap_project.project_id

  service_accounts = {
    "terraform-lz-runner" = {
      display_name = "Terraform Landing Zone CI/CD Runner"
      description  = "Service Account for automated Project Factory and Landing Zone execution"
    }
  }

  # --------------------------------------------------------------------------
  # Project-level permissions
  # --------------------------------------------------------------------------

  project_bindings = {
    "roles/viewer" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]
  }

  # --------------------------------------------------------------------------
  # Folder-level permissions
  # --------------------------------------------------------------------------

  folder_id = var.parent_folder_id

  folder_bindings = var.parent_folder_id != null ? {
    "roles/resourcemanager.folderAdmin" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]

    "roles/resourcemanager.projectCreator" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]

    "roles/compute.networkAdmin" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]

    "roles/compute.xpnAdmin" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]

    "roles/orgpolicy.policyAdmin" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]
  } : {}

  # --------------------------------------------------------------------------
  # Organization-level permissions
  # --------------------------------------------------------------------------

  org_id = var.parent_folder_id == null ? var.org_id : null

  org_bindings = var.parent_folder_id == null ? {
    "roles/resourcemanager.organizationAdmin" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]

    "roles/resourcemanager.projectCreator" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]

    "roles/compute.networkAdmin" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]

    "roles/compute.xpnAdmin" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]

    "roles/orgpolicy.policyAdmin" = [
      "serviceAccount:terraform-lz-runner@${module.bootstrap_project.project_id}.iam.gserviceaccount.com"
    ]
  } : {}

  depends_on = [
    module.bootstrap_services
  ]
}

# ==============================================================================
# 6. Grant Terraform Runner Access to State Buckets
# ==============================================================================

resource "google_storage_bucket_iam_member" "state_admin" {
  for_each = google_storage_bucket.tf_state

  bucket = each.value.name
  role   = "roles/storage.admin"

  member = "serviceAccount:${module.tf_runner_sa.service_account_emails["terraform-lz-runner"]}"
}