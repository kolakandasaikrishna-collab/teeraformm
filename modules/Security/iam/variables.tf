variable "project_id" {
  description = "The GCP project ID to apply project-level IAM roles and create service accounts."
  type        = string
  default     = null
}

variable "service_accounts" {
  description = "Map of service accounts to create. Key is account_id, value is object with display_name and description."
  type = map(object({
    display_name = string
    description  = optional(string, "Managed by Terraform")
  }))
  default = {}
}

variable "project_bindings" {
  description = "Map of project IAM role bindings in format { 'role' => ['member1', 'member2'] }."
  type        = map(list(string))
  default     = {}
}

variable "folder_id" {
  description = "Optional folder ID for folder-level IAM bindings."
  type        = string
  default     = null
}

variable "folder_bindings" {
  description = "Map of folder IAM role bindings in format { 'role' => ['member1', 'member2'] }."
  type        = map(list(string))
  default     = {}
}

variable "org_id" {
  description = "Optional organization ID for org-level IAM bindings."
  type        = string
  default     = null
}

variable "org_bindings" {
  description = "Map of org IAM role bindings in format { 'role' => ['member1', 'member2'] }."
  type        = map(list(string))
  default     = {}
}

variable "custom_roles" {
  description = "Map of custom project roles to create. Key is role_id."
  type = map(object({
    title       = string
    description = optional(string, "Custom IAM Role managed by Terraform")
    permissions = list(string)
    stage       = optional(string, "GA")
  }))
  default = {}
}
