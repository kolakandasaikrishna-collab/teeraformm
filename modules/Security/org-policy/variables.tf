variable "parent" {
  description = "The resource name of the parent where policies will be applied, e.g., 'organizations/123456789012' or 'folders/123456789012'."
  type        = string
}

variable "boolean_policies" {
  description = "Map of boolean constraint names to enforcement status (true = enforced, false = not enforced)."
  type        = map(bool)
  default = {
    "compute.disableGlobalSerialPortAccess"        = true
    "compute.skipDefaultNetworkCreation"          = true
    "storage.uniformBucketLevelAccess"             = true
    "iam.disableServiceAccountKeyCreation"         = true
    "compute.disableCustomerManagedIpForwarding"   = true
    "compute.disableVpcPeering"                   = true
  }
}

variable "list_policies" {
  description = "Map of list constraints and their allow/deny rules."
  type = map(object({
    inherit_from_parent = optional(bool, false)
    suggested_value     = optional(string, null)
    allow = optional(object({
      all    = optional(bool, null)
      values = optional(list(string), null)
    }), null)
    deny = optional(object({
      all    = optional(bool, null)
      values = optional(list(string), null)
    }), null)
  }))
  default = {
    "compute.vmExternalIpAccess" = {
      deny = {
        all = true
      }
    }
    "gcp.resourceLocations" = {
      allow = {
        values = [
          "in:asia-south1-locations",
          "in:us-central1-locations"
        ]
      }
    }
  }
}
