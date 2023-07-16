terraform {
  backend "gcs" {
    bucket = "mlops-prun-11082023-eedd-europe-central2-tfstate"
    prefix = "terraform/base"
  }
}
