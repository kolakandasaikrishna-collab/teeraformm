# Notification Channels
resource "google_monitoring_notification_channel" "channels" {
  for_each     = var.notification_channels
  project      = var.project_id
  display_name = each.value.display_name
  type         = each.value.type
  labels       = each.value.labels
  description  = each.value.description
  enabled      = each.value.enabled
}

# Alert Policies
resource "google_monitoring_alert_policy" "alert_policies" {
  for_each     = var.alert_policies
  project      = var.project_id
  display_name = each.value.display_name
  combiner     = each.value.combiner
  enabled      = each.value.enabled

  documentation {
    content   = each.value.documentation_content
    mime_type = "text/markdown"
  }

  notification_channels = [
    for key in each.value.notification_channel_keys :
    google_monitoring_notification_channel.channels[key].name
    if contains(keys(google_monitoring_notification_channel.channels), key)
  ]

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_threshold" {
        for_each = conditions.value.condition_threshold != null ? [conditions.value.condition_threshold] : []
        content {
          filter          = condition_threshold.value.filter
          duration        = condition_threshold.value.duration
          comparison      = condition_threshold.value.comparison
          threshold_value = condition_threshold.value.threshold_value

          dynamic "aggregations" {
            for_each = condition_threshold.value.aggregations
            content {
              alignment_period     = aggregations.value.alignment_period
              per_series_aligner   = aggregations.value.per_series_aligner
              cross_series_reducer = aggregations.value.cross_series_reducer
              group_by_fields      = aggregations.value.group_by_fields
            }
          }

          dynamic "trigger" {
            for_each = condition_threshold.value.trigger != null ? [condition_threshold.value.trigger] : []
            content {
              count   = trigger.value.count
              percent = trigger.value.percent
            }
          }
        }
      }

      dynamic "condition_absent" {
        for_each = conditions.value.condition_absent != null ? [conditions.value.condition_absent] : []
        content {
          filter   = condition_absent.value.filter
          duration = condition_absent.value.duration

          dynamic "trigger" {
            for_each = condition_absent.value.trigger != null ? [condition_absent.value.trigger] : []
            content {
              count   = trigger.value.count
              percent = trigger.value.percent
            }
          }
        }
      }
    }
  }
}

# Monitoring Dashboards
resource "google_monitoring_dashboard" "dashboards" {
  for_each       = var.dashboards
  project        = var.project_id
  dashboard_json = each.value.dashboard_json
}
