# ==============================================================================
# 1. NON-PROD / UAT PROJECTS
# ==============================================================================

# 1.1 Non-Prod Hub Project
module "hub_project" {
  source = "../../modules/project"

  name                = "network-hub-npd"
  project_id          = "network-hub-npd"
  org_id              = var.nonprod_folder_id == null ? var.org_id : null
  folder_id           = var.nonprod_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  labels = {
    environment    = var.environment
    cost-center    = "engineering"
    owner          = "network-infra"
    application_id = "hub-npd"
  }
}

# 1.2 DWH UAT Project
module "dwh_project" {
  source = "../../modules/project"

  name                = "dwh-uat-datalake"
  project_id          = "dwh-uat-datalake"
  org_id              = var.nonprod_folder_id == null ? var.org_id : null
  folder_id           = var.nonprod_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  labels = {
    environment    = var.environment
    cost-center    = "analytics"
    owner          = "dwh-team"
    application_id = "dwh-uat"
  }
}

# 1.3 AI Services UAT Project (Vertex AI / GPU Workloads)
module "ai_project" {
  source = "../../modules/project"

  name                = "ai-uat-platform"
  project_id          = "ai-uat-platform"
  org_id              = var.nonprod_folder_id == null ? var.org_id : null
  folder_id           = var.nonprod_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  labels = {
    environment    = var.environment
    cost-center    = "engineering"
    owner          = "ai-team"
    application_id = "ai-uat"
  }
}

# 1.4 Decoupled Sandbox AI Project (No NCC, Standalone VPC, Dedicated Cloud NAT)
module "sandbox_project" {
  source = "../../modules/project"

  name                = "sbx-ai-experiment"
  project_id          = "sbx-ai-experiment"
  org_id              = var.sandbox_folder_id == null ? var.org_id : null
  folder_id           = var.sandbox_folder_id
  billing_account     = var.billing_account_id
  auto_create_network = false
  random_project_id   = false
  labels = {
    environment    = "sbx"
    cost-center    = "engineering"
    owner          = "ai-research"
    application_id = "sbx-ai"
  }
}

# ==============================================================================
# 2. ENABLE SERVICES
# ==============================================================================

module "hub_services" {
  source     = "../../modules/project-services"
  project_id = module.hub_project.project_id
  services = [
    "compute.googleapis.com",
    "networkconnectivity.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
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
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

module "sandbox_services" {
  source     = "../../modules/project-services"
  project_id = module.sandbox_project.project_id
  services = [
    "aiplatform.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com"
  ]
}

# ==============================================================================
# 3. NETWORKING (10.200.0.0/16 PARENT ALLOCATION)
# ==============================================================================

# Hub VPC
resource "google_compute_network" "hub_vpc" {
  name                    = "network-hub-npd-vpc"
  project                 = module.hub_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [module.hub_services]
}

resource "google_compute_subnetwork" "hub_subnet" {
  name                     = "hub-npd-subnet"
  project                  = module.hub_project.project_id
  region                   = var.default_region
  network                  = google_compute_network.hub_vpc.id
  ip_cidr_range            = "10.200.160.0/24"
  private_ip_google_access = true
}

# DWH Spoke VPC
resource "google_compute_network" "dwh_vpc" {
  name                    = "dwh-uat-vpc"
  project                 = module.dwh_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [module.dwh_services]
}

resource "google_compute_subnetwork" "dwh_subnet" {
  name                     = "dwh-uat-subnet"
  project                  = module.dwh_project.project_id
  region                   = var.default_region
  network                  = google_compute_network.dwh_vpc.id
  ip_cidr_range            = "10.200.164.0/22"
  private_ip_google_access = true
}

# AI Services Spoke VPC
resource "google_compute_network" "ai_vpc" {
  name                    = "ai-uat-vpc"
  project                 = module.ai_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  depends_on              = [module.ai_services]
}

resource "google_compute_subnetwork" "ai_subnet" {
  name                     = "ai-uat-gpu-subnet"
  project                  = module.ai_project.project_id
  region                   = var.default_region
  network                  = google_compute_network.ai_vpc.id
  ip_cidr_range            = "10.200.176.0/22"
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.200.180.0/21"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.200.188.0/22"
  }
}

# AI VPC Cloud NAT for PyPI/HuggingFace fetching without public IPs
resource "google_compute_router" "ai_router" {
  name    = "ai-uat-nat-router"
  project = module.ai_project.project_id
  region  = var.default_region
  network = google_compute_network.ai_vpc.name
}

resource "google_compute_router_nat" "ai_nat" {
  name                               = "ai-uat-cloud-nat"
  project                            = module.ai_project.project_id
  router                             = google_compute_router.ai_router.name
  region                             = var.default_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Decoupled Sandbox Standalone VPC (No NCC, Strict Isolation)
resource "google_compute_network" "sandbox_vpc" {
  name                    = "sbx-ai-vpc"
  project                 = module.sandbox_project.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [module.sandbox_services]
}

resource "google_compute_subnetwork" "sandbox_subnet" {
  name                     = "sbx-ai-subnet"
  project                  = module.sandbox_project.project_id
  region                   = var.default_region
  network                  = google_compute_network.sandbox_vpc.id
  ip_cidr_range            = "10.200.240.0/25"
  private_ip_google_access = true
}

resource "google_compute_router" "sbx_router" {
  name    = "sbx-nat-router"
  project = module.sandbox_project.project_id
  region  = var.default_region
  network = google_compute_network.sandbox_vpc.name
}

resource "google_compute_router_nat" "sbx_nat" {
  name                               = "sbx-cloud-nat"
  project                            = module.sandbox_project.project_id
  router                             = google_compute_router.sbx_router.name
  region                             = var.default_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ==============================================================================
# 4. NETWORK CONNECTIVITY CENTER (NCC NON-PROD SPOKES)
# ==============================================================================

module "ncc" {
  source = "../../modules/ncc"

  project_id      = module.hub_project.project_id
  hub_name        = "ncc-hub-npd"
  hub_description = "NonProd NCC Hub linking UAT spokes (Isolated from Prod spokes)"

  vpc_spokes = {
    "dwh-uat-spoke" = {
      vpc_network_uri = google_compute_network.dwh_vpc.self_link
      description     = "DWH UAT Spoke"
    }
    "ai-uat-spoke" = {
      vpc_network_uri = google_compute_network.ai_vpc.self_link
      description     = "AI Platform UAT Spoke"
    }
  }

  labels = {
    environment = var.environment
  }

  depends_on = [
    module.hub_services,
    google_compute_network.dwh_vpc,
    google_compute_network.ai_vpc
  ]
}

# ==============================================================================
# 5. HA-VPN & PSC FOR GOOGLE APIS
# ==============================================================================

module "psc_google_apis" {
  source = "../../modules/psc"

  project_id                = module.hub_project.project_id
  network_id                = google_compute_network.hub_vpc.id
  enable_google_apis_psc    = true
  google_apis_ip_address    = "10.200.254.253"
  google_apis_endpoint_name = "psc-google-apis-npd"

  depends_on = [module.hub_services]
}

# ==============================================================================
# 6. FIREWALL BASELINES
# ==============================================================================

module "hub_firewall" {
  source = "../../modules/firewall"

  project_id                      = module.hub_project.project_id
  network_name                    = google_compute_network.hub_vpc.name
  enable_default_deny_all_ingress = true
  enable_allow_health_checks      = true
  enable_allow_iap_ssh_rdp        = true

  custom_rules = {
    "allow-nonprod-internal" = {
      description = "Allow NonProd internal traffic"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["10.200.160.0/19"]
      allow = [
        { protocol = "tcp" },
        { protocol = "udp" }
      ]
      enable_logging = true
    }
  }

  depends_on = [module.hub_services]
}

# ==============================================================================
# 7. SECURITY & OBSERVABILITY
# ==============================================================================

module "ai_security" {
  source = "../../modules/security"

  project_id = module.ai_project.project_id
  location   = var.default_region

  keyrings = {
    "uat-ai-keyring" = {
      keys = {
        "vertex-ai-uat-key" = {
          purpose         = "ENCRYPT_DECRYPT"
          rotation_period = "7776000s"
        }
      }
    }
  }

  depends_on = [module.ai_services]
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_id = module.hub_project.project_id

  notification_channels = {
    "email-channel" = {
      display_name = "Non-Prod Alert Channel"
      type         = "email"
      labels = {
        email_address = var.alert_notification_email
      }
    }
  }

  depends_on = [module.hub_services]
}
