module "infra" {
  source = "../modules/infra"

  env        = terraform.workspace
  project_id = var.project_id
  region     = var.region
  apps       = var.apps
}
