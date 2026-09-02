variable "project_id" {
  description = "The GCP project ID where Cloud Monitoring resources will be created."
  type        = string
}

variable "notification_channels" {
  description = "Map of notification channels to create."
  type = map(object({
    display_name = string
    type         = string # email, slack, pagerduty, webhook, pubsub
    labels       = map(string)
    description  = optional(string, "Notification channel managed by Terraform")
    enabled      = optional(bool, true)
  }))
  default = {}
}

variable "alert_policies" {
  description = "Map of Cloud Monitoring alert policies to create."
  type = map(object({
    display_name          = string
    combiner              = optional(string, "OR") # OR, AND, AND_WITH_MATCHING_RESOURCE
    enabled               = optional(bool, true)
    documentation_content = optional(string, "Alert triggered by Landing Zone monitoring policy.")
    notification_channel_keys = optional(list(string), []) # keys referencing notification_channels map
    conditions = list(object({
      display_name = string
      condition_threshold = optional(object({
        filter          = string
        duration        = string # e.g. "60s"
        comparison      = string # COMPARISON_GT, COMPARISON_LT, etc.
        threshold_value = number
        aggregations = optional(list(object({
          alignment_period     = string
          per_series_aligner   = string
          cross_series_reducer = optional(string, null)
          group_by_fields      = optional(list(string), [])
        })), [])
        trigger = optional(object({
          count   = optional(number, null)
          percent = optional(number, null)
        }), null)
      }), null)
      condition_absent = optional(object({
        filter   = string
        duration = string
        trigger = optional(object({
          count   = optional(number, null)
          percent = optional(number, null)
        }), null)
      }), null)
    }))
  }))
  default = {}
}

variable "dashboards" {
  description = "Map of dashboard JSON definitions to create."
  type = map(object({
    dashboard_json = string
  }))
  default = {}
}
