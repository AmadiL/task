terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.73.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "tfstate" {
  name          = var.bucket_name
  force_destroy = var.tfstate_force_destroy
  location      = var.region
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}
