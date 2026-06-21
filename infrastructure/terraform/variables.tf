# ── OCI Authentication ─────────────────────────────────────────────────────────
variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
  # Set via TF_VAR_tenancy_ocid or terraform.tfvars
}

variable "user_ocid" {
  description = "OCI User OCID"
  type        = string
}

variable "fingerprint" {
  description = "API Key fingerprint"
  type        = string
}

variable "private_key_path" {
  description = "Path to OCI API private key PEM file"
  type        = string
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "OCI region (e.g. ap-mumbai-1, us-ashburn-1)"
  type        = string
  default     = "ap-mumbai-1"
}

variable "compartment_id" {
  description = "OCI Compartment OCID where resources will be created"
  type        = string
}

# ── App Config ────────────────────────────────────────────────────────────────
variable "app_name" {
  description = "Application name (used for resource naming)"
  type        = string
  default     = "nexthome"
}

variable "environment" {
  description = "Deployment environment: dev | staging | prod"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# ── Network ───────────────────────────────────────────────────────────────────
variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

# ── Compute ───────────────────────────────────────────────────────────────────
variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  # Generate: ssh-keygen -t ed25519 -C nexthome-oci
}

variable "instance_shape" {
  description = "OCI compute shape"
  type        = string
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs"
  type        = number
  default     = 2
}

variable "instance_memory_gb" {
  description = "Memory in GB"
  type        = number
  default     = 8
}

variable "backend_docker_image" {
  description = "Docker image for backend (e.g. container-registry.oracle.com/nexthome/backend:latest)"
  type        = string
  default     = "nexthome/backend:latest"
}
