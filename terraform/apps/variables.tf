variable "project_id" {}

variable "region" {}

variable "cluster_name" {
  default = "cluster"
}

variable "tag" {}

variable "apps" {
  type = list(string)
}

variable "app_configs" {
  type = map(object({
    replicas = number
    containers = list(object({
      name = string
      port = number
      requests = object({
        cpu    = string
        memory = string
      })
      limits = object({
        cpu    = string
        memory = string
      })
      probe = object({
        path = string
        port = number
      })
    }))
    metrics = object({
      path = string
      port = number
    })
    autoscale = object({
      min                        = number
      max                        = number
      cpu_utilization_percentage = number
    })
  }))
}
