output "bootstrap_project_id" {
  description = "The unique ID of the bootstrap seed project."
  value       = module.bootstrap_project.project_id
}

output "terraform_service_account_email" {
  description = "Email of the Terraform automation service account."
  value       = module.tf_runner_sa.service_account_emails["terraform-lz-runner"]
}

output "state_buckets" {
  description = "Map of created Terraform state bucket names."
  value = {
    bootstrap = google_storage_bucket.tf_state["bootstrap"].name
    uat       = google_storage_bucket.tf_state["uat"].name
    prod      = google_storage_bucket.tf_state["prod"].name
  }
}

output "backend_config_instructions" {
  description = "Instructions for configuring backend.tf in environments."
  value = <<-EOT
    To configure your environment backends, update backend.tf:

    For UAT:
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.tf_state["uat"].name}"
        prefix = "environments/uat"
      }
    }

    For PROD:
    terraform {
      backend "gcs" {
        bucket = "${google_storage_bucket.tf_state["prod"].name}"
        prefix = "environments/prod"
      }
    }
  EOT
}
