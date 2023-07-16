# Enable Artifact Registry API
resource "google_project_service" "artifact_registry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Enable Compute API
resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.env}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-${var.env}-1"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"

  secondary_ip_range = [
    {
      range_name    = "cluster"
      ip_cidr_range = "10.10.1.0/24"
    },
    {
      range_name    = "services"
      ip_cidr_range = "10.11.0.0/16"
    }
  ]
}

# App docker repositories
resource "google_artifact_registry_repository" "app" {
  for_each = toset(var.apps)

  location      = var.region
  repository_id = "${each.key}-${var.env}"
  description   = "${each.key}-${var.env} docker repository"
  format        = "DOCKER"

  depends_on = [
    google_project_service.artifact_registry
  ]
}

# GKE cluster
resource "google_container_cluster" "gke" {
  # provider = google-beta
  name     = "cluster-${var.env}"
  location = var.region

  enable_autopilot = true

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.default-np.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/trace.append",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
      ]
    }
  }

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "10.12.0.0/28"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "cluster"
    services_secondary_range_name = "services"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
    }
  }
}

# Default Node Pool SA
resource "google_service_account" "default-np" {
  account_id = "cluster-${var.env}-default-np-sa"
}

locals {
  default_np_sa_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
    "roles/artifactregistry.reader",
    "roles/compute.securityAdmin",
  ]
}

resource "google_project_iam_member" "default-np" {
  for_each = toset(local.default_np_sa_roles)

  role    = each.key
  member  = google_service_account.default-np.member
  project = google_service_account.default-np.project
}
