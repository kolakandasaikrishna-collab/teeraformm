# ==============================================================================
# 1. PLATFORM FOLDER PROJECTS
# ==============================================================================

# 1.1 Central Networking Hub Project
module "network_hub_project" {
  source = "../../modules/project"

  name                = "network-hub-prd"
  project_id          = "network-hub-prd"
  org_id              = var.platform_folder_id == null ? var.org_id : null
  folder_id           = var.platform_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "engineering"
    owner          = "network-infra"
    application_id = "network-hub"
  }
}

# 1.2 Security & KMS Project
module "security_project" {
  source = "../../modules/project"

  name                = "security-prd"
  project_id          = "security-prd"
  org_id              = var.platform_folder_id == null ? var.org_id : null
  folder_id           = var.platform_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "security"
    owner          = "secops"
    application_id = "security-kms"
  }
}

# 1.3 Central Logging & SIEM Project
module "logging_project" {
  source = "../../modules/project"

  name                = "logging-prd"
  project_id          = "logging-prd"
  org_id              = var.platform_folder_id == null ? var.org_id : null
  folder_id           = var.platform_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "security"
    owner          = "secops"
    application_id = "central-logging"
  }
}

# 1.4 Central Monitoring & FinOps Project
module "monitoring_project" {
  source = "../../modules/project"

  name                = "monitoring-prd"
  project_id          = "monitoring-prd"
  org_id              = var.platform_folder_id == null ? var.org_id : null
  folder_id           = var.platform_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "finance"
    owner          = "finops"
    application_id = "monitoring-finops"
  }
}

# 1.5 Shared Services Project (Artifact Registry, PSC tools)
module "shared_services_project" {
  source = "../../modules/project"

  name                = "shared-services-prd"
  project_id          = "shared-services-prd"
  org_id              = var.platform_folder_id == null ? var.org_id : null
  folder_id           = var.platform_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "engineering"
    owner          = "platform-team"
    application_id = "shared-services"
  }
}

# ==============================================================================
# 2. BUSINESS DOMAIN WORKLOAD PROJECTS (PROD FOLDER)
# ==============================================================================

# 2.1 DWH Data Lake
module "dwh_project" {
  source = "../../modules/project"

  name                = "dwh-prd-datalake"
  project_id          = "dwh-prd-datalake"
  org_id              = var.prod_folder_id == null ? var.org_id : null
  folder_id           = var.prod_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "analytics"
    owner          = "dwh-team"
    application_id = "dwh-lake"
  }
}

# 2.2 BIU CKYC Application
module "biu_project" {
  source = "../../modules/project"

  name                = "biu-prd-ckyc"
  project_id          = "biu-prd-ckyc"
  org_id              = var.prod_folder_id == null ? var.org_id : null
  folder_id           = var.prod_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "analytics"
    owner          = "biu-team"
    application_id = "biu-ckyc"
  }
}

# 2.3 Core Application (Loan Platform)
module "app_project" {
  source = "../../modules/project"

  name                = "app-prd-loan"
  project_id          = "app-prd-loan"
  org_id              = var.prod_folder_id == null ? var.org_id : null
  folder_id           = var.prod_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "engineering"
    owner          = "app-dev"
    application_id = "loan-app"
  }
}

# 2.4 AI Services (Vertex AI, H100/L4 GPU GKE Platform)
module "ai_project" {
  source = "../../modules/project"

  name                = "ai-prd-platform"
  project_id          = "ai-prd-platform"
  org_id              = var.prod_folder_id == null ? var.org_id : null
  folder_id           = var.prod_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  deletion_policy     = "PREVENT"
  labels = {
    environment    = "prd"
    cost-center    = "engineering"
    owner          = "ai-team"
    application_id = "ai-platform"
  }
}

# ==============================================================================
# 3. ENABLE REQUIRED APIS ACROSS ALL PROJECTS
# ==============================================================================

module "hub_services" {
  source     = "../../modules/project-services"
  project_id = module.network_hub_project.project_id
  services = [
    "compute.googleapis.com",
    "networkconnectivity.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

module "security_services" {
  source     = "../../modules/project-services"
  project_id = module.security_project.project_id
  services = [
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

module "logging_services" {
  source     = "../../modules/project-services"
  project_id = module.logging_project.project_id
  services = [
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

module "monitoring_services" {
  source     = "../../modules/project-services"
  project_id = module.monitoring_project.project_id
  services = [
    "bigquery.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudbilling.googleapis.com"
  ]
}

module "shared_services" {
  source     = "../../modules/project-services"
  project_id = module.shared_services_project.project_id
  services = [
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

module "dwh_services" {
  source     = "../../modules/project-services"
  project_id = module.dwh_project.project_id
  services = [
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

module "biu_services" {
  source     = "../../modules/project-services"
  project_id = module.biu_project.project_id
  services = [
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

module "app_services" {
  source     = "../../modules/project-services"
  project_id = module.app_project.project_id
  services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

module "ai_services" {
  source     = "../../modules/project-services"
  project_id = module.ai_project.project_id
  services = [
    "aiplatform.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

# ==============================================================================
# 4. ENTERPRISE IP SUBNETTING (10.200.0.0/16 PARENT ALLOCATION)
# ==============================================================================

# 4.1 Hub VPC (10.200.0.0/22)
resource "google_compute_network" "hub_vpc" {
  name                    = "network-hub-prd-vpc"
  project                 = module.network_hub_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [module.hub_services]
}

resource "google_compute_subnetwork" "hub_primary_subnet" {
  name                     = "hub-subnet-${var.primary_region}"
  project                  = module.network_hub_project.project_id
  region                   = var.primary_region
  network                  = google_compute_network.hub_vpc.id
  ip_cidr_range            = "10.200.0.0/24"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "hub_secondary_subnet" {
  name                     = "hub-subnet-${var.secondary_region}"
  project                  = module.network_hub_project.project_id
  region                   = var.secondary_region
  network                  = google_compute_network.hub_vpc.id
  ip_cidr_range            = "10.200.1.0/24"
  private_ip_google_access = true
}

# 4.2 DWH Spoke VPC (10.200.32.0/19 Boundary)
resource "google_compute_network" "dwh_vpc" {
  name                    = "dwh-prd-vpc"
  project                 = module.dwh_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [module.dwh_services]
}

resource "google_compute_subnetwork" "dwh_primary_subnet" {
  name                     = "dwh-pri-subnet"
  project                  = module.dwh_project.project_id
  region                   = var.primary_region
  network                  = google_compute_network.dwh_vpc.id
  ip_cidr_range            = "10.200.32.0/22"
  private_ip_google_access = true
}

# 4.3 BIU Spoke VPC (10.200.64.0/19 Boundary)
resource "google_compute_network" "biu_vpc" {
  name                    = "biu-prd-vpc"
  project                 = module.biu_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [module.biu_services]
}

resource "google_compute_subnetwork" "biu_primary_subnet" {
  name                     = "biu-pri-subnet"
  project                  = module.biu_project.project_id
  region                   = var.primary_region
  network                  = google_compute_network.biu_vpc.id
  ip_cidr_range            = "10.200.64.0/22"
  private_ip_google_access = true
}

# 4.4 App Spoke VPC (10.200.96.0/19 Boundary)
resource "google_compute_network" "app_vpc" {
  name                    = "app-prd-vpc"
  project                 = module.app_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [module.app_services]
}

resource "google_compute_subnetwork" "app_primary_subnet" {
  name                     = "app-pri-subnet"
  project                  = module.app_project.project_id
  region                   = var.primary_region
  network                  = google_compute_network.app_vpc.id
  ip_cidr_range            = "10.200.96.0/22"
  private_ip_google_access = true
}

# 4.5 AI Services Spoke VPC (10.200.128.0/19 Boundary - GPU & Vertex AI Ready)
resource "google_compute_network" "ai_vpc" {
  name                    = "ai-prd-vpc"
  project                 = module.ai_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [module.ai_services]
}

resource "google_compute_subnetwork" "ai_primary_subnet" {
  name                     = "ai-gpu-node-subnet"
  project                  = module.ai_project.project_id
  region                   = var.primary_region
  network                  = google_compute_network.ai_vpc.id
  ip_cidr_range            = "10.200.128.0/22" # VM / GPU Primary Nodes
  private_ip_google_access = true

  # GKE Secondary Alias Ranges for H100/L4 GPU Inference Clusters
  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.200.132.0/20" # 4,096 Pod IPs
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.200.148.0/22" # 1,024 Service IPs
  }
}

# Cloud NAT for AI VPC (Outbound PyPI/HuggingFace fetching without Public IPs)
resource "google_compute_router" "ai_nat_router" {
  name    = "ai-nat-router"
  project = module.ai_project.project_id
  region  = var.primary_region
  network = google_compute_network.ai_vpc.name
}

resource "google_compute_router_nat" "ai_cloud_nat" {
  name                               = "ai-cloud-nat"
  project                            = module.ai_project.project_id
  router                             = google_compute_router.ai_nat_router.name
  region                             = var.primary_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ==============================================================================
# 5. NETWORK CONNECTIVITY CENTER (NCC STAR TOPOLOGY)
# ==============================================================================

module "ncc_hub" {
  source = "../../modules/ncc"

  project_id      = module.network_hub_project.project_id
  hub_name        = "ncc-star-hub-prd"
  hub_description = "Central NCC Star Hub interconnecting AWS and Dedicated Workload Spokes"

  vpc_spokes = {
    "dwh-spoke" = {
      vpc_network_uri = google_compute_network.dwh_vpc.self_link
      description     = "DWH Data Lake Dedicated Spoke"
    }
    "biu-spoke" = {
      vpc_network_uri = google_compute_network.biu_vpc.self_link
      description     = "BIU Dedicated Spoke"
    }
    "app-spoke" = {
      vpc_network_uri = google_compute_network.app_vpc.self_link
      description     = "Core App Dedicated Spoke"
    }
    "ai-spoke" = {
      vpc_network_uri = google_compute_network.ai_vpc.self_link
      description     = "AI Services & GPU Cluster Dedicated Spoke"
    }
  }

  labels = {
    environment = "prd"
  }

  depends_on = [
    module.hub_services,
    google_compute_network.dwh_vpc,
    google_compute_network.biu_vpc,
    google_compute_network.app_vpc,
    google_compute_network.ai_vpc
  ]
}

# ==============================================================================
# 6. HYBRID CONNECTIVITY (HA-VPN TO AWS TRANSIT GATEWAY)
# ==============================================================================

module "aws_hybrid_vpn" {
  source = "../../modules/ha-vpn"

  project_id       = module.network_hub_project.project_id
  region           = var.primary_region
  network          = google_compute_network.hub_vpc.id
  vpn_gateway_name = "gcp-aws-tgw-ha-vpn"
  router_name      = "gcp-aws-hybrid-router"
  router_asn       = 65001

  peer_external_gateway = {
    name            = "aws-tgw-customer-gateway"
    redundancy_type = "TWO_IPS_REDUNDANCY"
    interfaces = [
      { id = 0, ip_address = var.aws_tgw_ip_addresses[0] },
      { id = 1, ip_address = var.aws_tgw_ip_addresses[1] }
    ]
  }

  tunnels = {
    tunnel-0 = {
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = "Enterprise-AWS-GCP-Hybrid-Secret-0"
      router_interface_ip             = "169.254.100.1/30"
      bgp_peer = {
        name                      = "aws-tgw-peer-0"
        peer_asn                  = var.aws_tgw_asn
        peer_ip_address           = "169.254.100.2"
        advertised_route_priority = 100
      }
    }
    tunnel-1 = {
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = "Enterprise-AWS-GCP-Hybrid-Secret-1"
      router_interface_ip             = "169.254.100.5/30"
      bgp_peer = {
        name                      = "aws-tgw-peer-1"
        peer_asn                  = var.aws_tgw_asn
        peer_ip_address           = "169.254.100.6"
        advertised_route_priority = 100
      }
    }
  }

  depends_on = [module.hub_services]
}

# ==============================================================================
# 7. FIREWALL BASELINES & HIERARCHICAL PERIMETER
# ==============================================================================

module "hub_firewall" {
  source = "../../modules/firewall"

  project_id                      = module.network_hub_project.project_id
  network_name                    = google_compute_network.hub_vpc.name
  enable_default_deny_all_ingress = true
  enable_allow_health_checks      = true
  enable_allow_iap_ssh_rdp        = true

  custom_rules = {
    "allow-internal-10-200" = {
      description = "Allow internal GCP parent allocation 10.200.0.0/16"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["10.200.0.0/16"]
      allow = [
        { protocol = "tcp" },
        { protocol = "udp" },
        { protocol = "icmp" }
      ]
      enable_logging = true
    }
  }

  depends_on = [module.hub_services]
}

module "ai_firewall" {
  source = "../../modules/firewall"

  project_id                      = module.ai_project.project_id
  network_name                    = google_compute_network.ai_vpc.name
  enable_default_deny_all_ingress = true
  enable_allow_health_checks      = true
  enable_allow_iap_ssh_rdp        = true

  custom_rules = {
    "allow-hub-to-ai" = {
      description = "Allow Hub to AI Platform"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["10.200.0.0/22"]
      allow = [
        { protocol = "tcp", ports = ["80", "443", "8080", "8443", "5000", "8000"] }
      ]
      enable_logging = true
    }
  }

  depends_on = [module.ai_services]
}

# ==============================================================================
# 8. PRIVATE SERVICE CONNECT (PSC) FOR GOOGLE APIS (VERTEX AI / GEMINI / BQ)
# ==============================================================================

module "psc_google_apis" {
  source = "../../modules/psc"

  project_id                = module.network_hub_project.project_id
  network_id                = google_compute_network.hub_vpc.id
  enable_google_apis_psc    = true
  google_apis_ip_address    = "10.200.254.254"
  google_apis_endpoint_name = "psc-google-apis-prd"

  depends_on = [module.hub_services]
}

# ==============================================================================
# 9. CLOUD DNS (PRIVATE ENTERPRISE DOMAIN)
# ==============================================================================

module "cloud_dns" {
  source = "../../modules/dns"

  project_id = module.network_hub_project.project_id

  managed_zones = {
    "enterprise-internal-zone" = {
      dns_name    = "gcp.corp.internal."
      description = "Internal Private Cloud DNS Zone"
      visibility  = "private"
      private_visibility_config = {
        networks = [
          google_compute_network.hub_vpc.self_link,
          google_compute_network.dwh_vpc.self_link,
          google_compute_network.biu_vpc.self_link,
          google_compute_network.app_vpc.self_link,
          google_compute_network.ai_vpc.self_link
        ]
      }
    }
  }

  record_sets = {
    "psc-apis" = {
      zone_key = "enterprise-internal-zone"
      name     = "apis.gcp.corp.internal."
      type     = "A"
      ttl      = 300
      rrdatas  = ["10.200.254.254"]
    }
    "ai-endpoint" = {
      zone_key = "enterprise-internal-zone"
      name     = "ai-model.gcp.corp.internal."
      type     = "A"
      ttl      = 300
      rrdatas  = ["10.200.128.10"]
    }
  }

  enable_logging_policy = true
  dns_policy_networks   = [google_compute_network.hub_vpc.self_link]

  depends_on = [module.hub_services]
}

# ==============================================================================
# 10. SECURITY: CLOUD KMS (CMEK) & CLOUD ARMOR WAF
# ==============================================================================

module "security" {
  source = "../../modules/security"

  project_id = module.security_project.project_id
  location   = var.primary_region

  keyrings = {
    "prd-ai-cmek-keyring" = {
      keys = {
        "vertex-ai-key" = {
          purpose         = "ENCRYPT_DECRYPT"
          rotation_period = "7776000s" # 90 days automatic rotation
        }
        "dwh-bigquery-key" = {
          purpose         = "ENCRYPT_DECRYPT"
          rotation_period = "7776000s"
        }
        "gcs-artifacts-key" = {
          purpose         = "ENCRYPT_DECRYPT"
          rotation_period = "7776000s"
        }
      }
    }
  }

  cloud_armor_policies = {
    "edge-waf-rate-limiting" = {
      description = "Edge WAF Policy with Rate Limiting and OWASP Rules"
      rules = [
        {
          action      = "allow"
          priority    = 1000
          description = "Allow internal GCP / AWS range"
          match = {
            versioned_expr = "SRC_IPS_V1"
            config = {
              src_ip_ranges = ["10.200.0.0/16", "10.0.0.0/8"]
            }
          }
        },
        {
          action      = "throttle"
          priority    = 2000
          description = "Rate Limit 1000 requests per minute"
          match = {
            versioned_expr = "SRC_IPS_V1"
            config = {
              src_ip_ranges = ["*"]
            }
          }
          rate_limit_options = {
            conform_action = "allow"
            exceed_action  = "deny(429)"
            enforce_on_key = "IP"
            rate_limit_threshold = {
              count        = 1000
              interval_sec = 60
            }
          }
        },
        {
          action      = "deny(403)"
          priority    = 2147483647
          description = "Default Deny"
          match = {
            versioned_expr = "SRC_IPS_V1"
            config = {
              src_ip_ranges = ["*"]
            }
          }
        }
      ]
    }
  }

  depends_on = [module.security_services]
}

# ==============================================================================
# 11. CENTRALIZED LOGGING & SIEM (LOGGING-PRD)
# ==============================================================================

module "central_logging" {
  source = "../../modules/logging"

  project_id              = module.logging_project.project_id
  location                = var.primary_region
  create_storage_bucket   = true
  storage_bucket_name     = "${module.logging_project.project_id}-audit-archive"
  log_retention_days      = 365
  create_bigquery_dataset = true
  bigquery_dataset_id     = "central_audit_logs_prd"

  project_sinks = {
    "all-audit-logs" = {
      destination = "storage.googleapis.com/${module.logging_project.project_id}-audit-archive"
      filter      = "logName:\"logs/cloudaudit.googleapis.com\""
    }
  }

  depends_on = [module.logging_services]
}

# ==============================================================================
# 12. PROACTIVE OBSERVABILITY & FINOPS (MONITORING-PRD)
# ==============================================================================

module "monitoring" {
  source = "../../modules/monitoring"

  project_id = module.monitoring_project.project_id

  notification_channels = {
    "secops-email" = {
      display_name = "SecOps & Cloud Engineering Alerts"
      type         = "email"
      labels = {
        email_address = var.alert_notification_email
      }
    }
  }

  alert_policies = {
    "gpu-high-utilization" = {
      display_name              = "[PROD] GPU / Compute High Utilization (>85%)"
      combiner                  = "OR"
      notification_channel_keys = ["secops-email"]
      documentation_content     = "Critical: Production GPU / VM Compute utilization sustained above 85%."
      conditions = [
        {
          display_name = "Compute CPU usage high"
          condition_threshold = {
            filter          = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
            duration        = "300s"
            comparison      = "COMPARISON_GT"
            threshold_value = 0.85
            aggregations = [
              {
                alignment_period   = "60s"
                per_series_aligner = "ALIGN_MEAN"
              }
            ]
          }
        }
      ]
    }
  }

  depends_on = [module.monitoring_services]
}

# ==============================================================================
# 13. ENTERPRISE ORGANIZATION POLICY GUARDRAILS (PROGRAMMATIC SCPS)
# ==============================================================================

module "org_policies" {
  count  = var.prod_folder_id != null ? 1 : 0
  source = "../../modules/org-policy"

  parent = var.prod_folder_id

  boolean_policies = {
    "compute.disableGlobalSerialPortAccess"      = true
    "compute.skipDefaultNetworkCreation"        = true
    "storage.uniformBucketLevelAccess"           = true
    "iam.disableServiceAccountKeyCreation"       = true
    "compute.disableCustomerManagedIpForwarding" = true
    "compute.disableVpcPeering"                 = true
  }

  list_policies = {
    "compute.vmExternalIpAccess" = {
      deny = {
        all = true # Zero Public IPs on compute
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
