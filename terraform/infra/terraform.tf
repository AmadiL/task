terraform {
  backend "gcs" {}
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.73.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "google" {
  project = var.project_id
  region  = var.region
}
