terraform {
  required_version = ">= 1.5.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
  # Uncomment for remote state on OCI Object Storage:
  # backend "s3" {
  #   bucket   = "nexthome-tf-state"
  #   key      = "terraform.tfstate"
  #   region   = var.region
  #   endpoint = "https://<namespace>.compat.objectstorage.<region>.oraclecloud.com"
  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   force_path_style            = true
  # }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# ── Networking ─────────────────────────────────────────────────────────────────
module "network" {
  source           = "./modules/network"
  compartment_id   = var.compartment_id
  vcn_cidr         = var.vcn_cidr
  app_name         = var.app_name
  environment      = var.environment
}

# ── Compute (Backend API Server) ───────────────────────────────────────────────
module "compute" {
  source              = "./modules/compute"
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  subnet_id           = module.network.public_subnet_id
  ssh_public_key      = var.ssh_public_key
  instance_shape      = var.instance_shape
  instance_ocpus      = var.instance_ocpus
  instance_memory_gb  = var.instance_memory_gb
  app_name            = var.app_name
  environment         = var.environment
  node_port           = 3000
  docker_image        = var.backend_docker_image
}

# ── Object Storage (Media uploads) ────────────────────────────────────────────
resource "oci_objectstorage_bucket" "media" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.app_name}-media-${var.environment}"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}

# ── Load Balancer (Optional – enable for production HA) ───────────────────────
# Uncomment for multi-instance setup:
# resource "oci_load_balancer_load_balancer" "lb" { ... }

# ── Data Sources ───────────────────────────────────────────────────────────────
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_id
}
