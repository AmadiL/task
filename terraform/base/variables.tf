variable "project_id" {}

variable "region" {}

variable "bucket_name" {}

variable "tfstate_force_destroy" {
  type    = bool
  default = false
}
