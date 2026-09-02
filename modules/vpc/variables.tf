# ==============================================================================
# VPC Module Variables
# ==============================================================================


# ------------------------------------------------------------------------------
# Project Configuration
# ------------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID where the VPC will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must not be empty."
  }
}


# ------------------------------------------------------------------------------
# VPC Configuration
# ------------------------------------------------------------------------------

variable "vpc_name" {
  description = "Name of the VPC network."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.vpc_name))
    error_message = "vpc_name must be a valid GCP resource name."
  }
}


variable "vpc_description" {
  description = "Description of the VPC network."
  type        = string
  default     = "VPC network created by Terraform."
}


variable "routing_mode" {
  description = "VPC routing mode."
  type        = string
  default     = "GLOBAL"

  validation {
    condition = contains(
      ["REGIONAL", "GLOBAL"],
      upper(var.routing_mode)
    )

    error_message = "routing_mode must be either REGIONAL or GLOBAL."
  }
}


# ------------------------------------------------------------------------------
# Primary Subnet
# ------------------------------------------------------------------------------

variable "primary_region" {
  description = "Region where the primary subnet will be created."
  type        = string

  validation {
    condition     = length(trimspace(var.primary_region)) > 0
    error_message = "primary_region must not be empty."
  }
}


variable "primary_subnet_name" {
  description = "Name of the primary subnet."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.primary_subnet_name))
    error_message = "primary_subnet_name must be a valid GCP resource name."
  }
}


variable "primary_subnet_cidr" {
  description = "CIDR range for the primary subnet."
  type        = string

  validation {
    condition     = can(cidrhost(var.primary_subnet_cidr, 0))
    error_message = "primary_subnet_cidr must be a valid CIDR block."
  }
}


variable "primary_subnet_description" {
  description = "Description of the primary subnet."
  type        = string
  default     = "Primary subnet for VPC."
}


variable "private_ip_google_access" {
  description = "Enable Private Google Access on the subnets."
  type        = bool
  default     = true
}


# ------------------------------------------------------------------------------
# Secondary Subnet
# ------------------------------------------------------------------------------

variable "enable_secondary_subnet" {
  description = "Whether to create a secondary subnet."
  type        = bool
  default     = false
}


variable "secondary_region" {
  description = "Region for the secondary subnet."
  type        = string
  default     = ""

  validation {
    condition = (
      !var.enable_secondary_subnet ||
      length(trimspace(var.secondary_region)) > 0
    )

    error_message = "secondary_region must be provided when enable_secondary_subnet is true."
  }
}


variable "secondary_subnet_name" {
  description = "Name of the secondary subnet."
  type        = string
  default     = ""

  validation {
    condition = (
      !var.enable_secondary_subnet ||
      length(trimspace(var.secondary_subnet_name)) > 0
    )

    error_message = "secondary_subnet_name must be provided when enable_secondary_subnet is true."
  }
}


variable "secondary_subnet_cidr" {
  description = "CIDR range for the secondary subnet."
  type        = string
  default     = ""

  validation {
    condition = (
      !var.enable_secondary_subnet ||
      can(cidrhost(var.secondary_subnet_cidr, 0))
    )

    error_message = "secondary_subnet_cidr must be a valid CIDR when enable_secondary_subnet is true."
  }
}


variable "secondary_subnet_description" {
  description = "Description of the secondary subnet."
  type        = string
  default     = "Secondary subnet for VPC."
}


# ------------------------------------------------------------------------------
# GKE Secondary IP Ranges
# ------------------------------------------------------------------------------

variable "enable_secondary_ip_ranges" {
  description = "Whether to create GKE secondary IP ranges."
  type        = bool
  default     = false
}


variable "secondary_ip_ranges" {
  description = "Secondary IP ranges for the primary subnet. Typically used for GKE Pods and Services."

  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))

  default = []
}


variable "secondary_secondary_ip_ranges" {
  description = "Secondary IP ranges for the secondary subnet."

  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))

  default = []
}


# ------------------------------------------------------------------------------
# Cloud NAT Configuration
# ------------------------------------------------------------------------------

variable "enable_cloud_nat" {
  description = "Whether to create Cloud Router and Cloud NAT."
  type        = bool
  default     = false
}


variable "router_name" {
  description = "Name of the primary Cloud Router."
  type        = string
  default     = ""
}


variable "router_description" {
  description = "Description of the primary Cloud Router."
  type        = string
  default     = "Cloud Router for Cloud NAT."
}


variable "nat_name" {
  description = "Name of the primary Cloud NAT."
  type        = string
  default     = ""
}


variable "nat_ip_allocate_option" {
  description = "Cloud NAT IP allocation mode."
  type        = string
  default     = "AUTO_ONLY"

  validation {
    condition = contains(
      ["AUTO_ONLY", "MANUAL_ONLY"],
      upper(var.nat_ip_allocate_option)
    )

    error_message = "nat_ip_allocate_option must be AUTO_ONLY or MANUAL_ONLY."
  }
}


# ------------------------------------------------------------------------------
# Primary NAT IPs
# ------------------------------------------------------------------------------

variable "nat_ips" {
  description = "List of self-links of reserved external IP addresses for primary Cloud NAT when MANUAL_ONLY is used."
  type        = list(string)
  default     = null

  validation {
    condition = (
      upper(var.nat_ip_allocate_option) != "MANUAL_ONLY" ||
      var.nat_ips != null
    )

    error_message = "nat_ips must be provided when nat_ip_allocate_option is MANUAL_ONLY."
  }
}


# ------------------------------------------------------------------------------
# Secondary NAT IPs
# ------------------------------------------------------------------------------

variable "secondary_nat_ips" {
  description = "List of self-links of reserved external IP addresses for secondary Cloud NAT when MANUAL_ONLY is used."
  type        = list(string)
  default     = null

  validation {
    condition = (
      !var.enable_secondary_subnet ||
      upper(var.nat_ip_allocate_option) != "MANUAL_ONLY" ||
      var.secondary_nat_ips != null
    )

    error_message = "secondary_nat_ips must be provided when secondary NAT uses MANUAL_ONLY."
  }
}


# ------------------------------------------------------------------------------
# NAT Source Subnetworks
# ------------------------------------------------------------------------------

variable "nat_source_subnetwork_ip_ranges" {
  description = "Which IP ranges from subnetworks should use Cloud NAT."
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  validation {
    condition = contains(
      [
        "ALL_SUBNETWORKS_ALL_IP_RANGES",
        "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES",
        "LIST_OF_SUBNETWORKS"
      ],
      upper(var.nat_source_subnetwork_ip_ranges)
    )

    error_message = "nat_source_subnetwork_ip_ranges must be a valid Cloud NAT source range option."
  }
}


# ------------------------------------------------------------------------------
# NAT Logging
# ------------------------------------------------------------------------------

variable "enable_nat_logging" {
  description = "Whether to enable Cloud NAT logging."
  type        = bool
  default     = false
}


variable "nat_logging_filter" {
  description = "Cloud NAT logging filter."
  type        = string
  default     = "ERRORS_ONLY"

  validation {
    condition = contains(
      [
        "ERRORS_ONLY",
        "TRANSLATIONS_ONLY",
        "ALL"
      ],
      upper(var.nat_logging_filter)
    )

    error_message = "nat_logging_filter must be ERRORS_ONLY, TRANSLATIONS_ONLY, or ALL."
  }
}