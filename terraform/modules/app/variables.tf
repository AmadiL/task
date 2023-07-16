variable "name" {
  type        = string
  description = "App name"
}

variable "tag" {
  type = string
}

variable "repository" {
  type        = string
  description = "App Docker repository URL"
}

variable "config" {
  type = object({
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
  })
}
