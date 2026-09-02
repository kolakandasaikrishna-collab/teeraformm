# Boolean Organization Policies (v2 API)
resource "google_org_policy_policy" "boolean_policies" {
  for_each = var.boolean_policies
  name     = "${var.parent}/policies/${each.key}"
  parent   = var.parent

  spec {
    rules {
      enforce = each.value ? "TRUE" : "FALSE"
    }
  }
}

# List Organization Policies (v2 API)
resource "google_org_policy_policy" "list_policies" {
  for_each = var.list_policies
  name     = "${var.parent}/policies/${each.key}"
  parent   = var.parent

  spec {
    inherit_from_parent = each.value.inherit_from_parent

    dynamic "rules" {
      for_each = each.value.allow != null ? [each.value.allow] : []
      content {
        values {
          allowed_values = rules.value.values
        }
        allow_all = rules.value.all != null ? (rules.value.all ? "TRUE" : "FALSE") : null
      }
    }

    dynamic "rules" {
      for_each = each.value.deny != null ? [each.value.deny] : []
      content {
        values {
          denied_values = rules.value.values
        }
        deny_all = rules.value.all != null ? (rules.value.all ? "TRUE" : "FALSE") : null
      }
    }
  }
}
