variable "project_id" {
  description = "The GCP project ID where security resources (KMS, Cloud Armor) are created."
  type        = string
}

variable "location" {
  description = "The GCP location/region for Cloud KMS keyrings."
  type        = string
  default     = "us-central1"
}

variable "keyrings" {
  description = "Map of Cloud KMS Key Rings and their Crypto Keys."
  type = map(object({
    keys = map(object({
      purpose          = optional(string, "ENCRYPT_DECRYPT")
      rotation_period  = optional(string, "7776000s") # 90 days
      encrypter_decrypter_members = optional(list(string), [])
    }))
  }))
  default = {}
}

variable "cloud_armor_policies" {
  description = "Map of Cloud Armor security policies."
  type = map(object({
    description = optional(string, "Cloud Armor Security Policy managed by Terraform")
    rules = list(object({
      action      = string # allow, deny(403), deny(404), deny(502), throttle, rate_based_ban
      priority    = number
      description = optional(string, "")
      match = object({
        versioned_expr = optional(string, "SRC_IPS_V1")
        config = optional(object({
          src_ip_ranges = list(string)
        }), null)
        expr = optional(object({
          expression = string
        }), null)
      })
      rate_limit_options = optional(object({
        conform_action    = string
        exceed_action     = string
        enforce_on_key    = string
        rate_limit_threshold = object({
          count        = number
          interval_sec = number
        })
      }), null)
    }))
  }))
  default = {}
}
