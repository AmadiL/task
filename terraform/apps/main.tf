locals {
  env      = terraform.workspace
  registry = "${var.region}-docker.pkg.dev"
}

module "apps" {
  for_each = toset(var.apps)

  source = "../modules/app"

  name       = "${each.key}-${local.env}"
  config     = var.app_configs[each.key]
  repository = "${local.registry}/${var.project_id}/${each.key}-${local.env}"
  tag        = var.tag
}
