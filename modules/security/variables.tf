variable "project_id" {
  description = "GCP project ID where keyrings/keys will be referenced"
  type        = string
}

variable "location" {
  description = "GCP region/location for keyrings and keys"
  type        = string
}

variable "keyrings" {
  description = "Nested map describing keyrings and keys. Example shape:
    {
      "tf-state-keyring" = {
        keys = {
          "tf-state-key" = {
            rotation_period = "7776000s"
          }
        }
      }
    }
  "
  type    = any
  default = {}
}
