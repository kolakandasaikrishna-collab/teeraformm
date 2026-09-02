# ==============================================================================
# Bootstrap Project
# ==============================================================================

output "bootstrap_project_id" {
  description = "The unique ID of the bootstrap / automation project."
  value       = module.bootstrap_project.project_id
}

# ==============================================================================
# Terraform Automation Service Account
# ==============================================================================

output "terraform_service_account_email" {
  description = "Email address of the Terraform automation service account."
  value       = module.tf_runner_sa.service_account_emails["terraform-lz-runner"]
}

# ==============================================================================
# Terraform State Buckets
# ==============================================================================

output "state_buckets" {
  description = "Map of Terraform state bucket names."

  value = {
    bootstrap = google_storage_bucket.tf_state["bootstrap"].name
    uat       = google_storage_bucket.tf_state["uat"].name
    prod      = google_storage_bucket.tf_state["prod"].name
  }
}

# ==============================================================================
# Terraform Backend Configuration
# ==============================================================================

output "backend_config_instructions" {
  description = "Instructions for configuring Terraform GCS backends."

  value = <<-EOT
    Configure the Terraform backend as follows:

    BOOTSTRAP:
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.tf_state["bootstrap"].name}"
        prefix = "environments/bootstrap"
      }
    }

    UAT:
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.tf_state["uat"].name}"
        prefix = "environments/uat"
      }
    }

    PROD:
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.tf_state["prod"].name}"
        prefix = "environments/prod"
      }
    }
  EOT
}