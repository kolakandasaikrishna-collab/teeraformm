variable "name" {
  description = "The name for the project to be created."
  type        = string
}

variable "project_id" {
  description = "The custom project ID. If random_project_id is true, this acts as a prefix."
  type        = string
}

variable "random_project_id" {
  description = "Whether to append a random suffix to project_id to ensure global uniqueness."
  type        = bool
  default     = true
}

variable "org_id" {
  description = "The numeric Organization ID. If folder_id is specified, folder_id takes precedence."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "The numeric Folder ID where the project will be created."
  type        = string
  default     = null
}

variable "billing_account" {
  description = "The alpha-numeric Billing Account ID to link with this project."
  type        = string
  default     = null
}

variable "auto_create_network" {
  description = "Whether to create the default network. Default is false for security best practices."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Map of key-value labels to assign to the project."
  type        = map(string)
  default     = {}
}

variable "deletion_policy" {
  description = "The deletion policy for the project. Can be PREVENT, ABANDON, or DELETE."
  type        = string
  default     = "PREVENT"
  validation {
    condition     = contains(["PREVENT", "ABANDON", "DELETE"], var.deletion_policy)
    error_message = "deletion_policy must be one of PREVENT, ABANDON, or DELETE."
  }
}
