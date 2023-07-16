variable "env" {
  type        = string
  description = "Environemnt name: dev, prod"
}

variable "project_id" {
  type        = string
  description = "GCP project id"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "apps" {
  type        = list(string)
  description = "List of app names"
}
