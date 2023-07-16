locals {
  app_labels = {
    app = var.name
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name   = var.name
    labels = local.app_labels
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.app.metadata.0.name
    labels    = local.app_labels
  }

  spec {
    replicas = var.config.replicas
    selector {
      match_labels = local.app_labels
    }
    template {
      metadata {
        labels = local.app_labels
      }
      spec {
        dynamic "container" {
          for_each = var.config.containers
          content {
            image = "${var.repository}/${container.value.name}:${var.tag}"
            name  = container.value.name

            port {
              name           = "http"
              container_port = container.value.port
              protocol       = "TCP"
            }

            resources {
              requests = container.value.requests

              limits = container.value.limits
            }

            liveness_probe {
              http_get {
                path = container.value.probe.path
                port = container.value.probe.port
              }
              initial_delay_seconds = 15
              period_seconds        = 15
              timeout_seconds       = 10
            }

            readiness_probe {
              http_get {
                path = container.value.probe.path
                port = container.value.probe.port
              }
              initial_delay_seconds = 15
              timeout_seconds       = 10
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.name}-svc"
    namespace = kubernetes_namespace.app.metadata.0.name
  }
  spec {
    type     = "NodePort"
    selector = local.app_labels
    port {
      name        = "http"
      port        = 80
      target_port = "http"
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "${var.name}-external"
    namespace = kubernetes_namespace.app.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class" = "gce"
    }
  }
  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app.metadata.0.name
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "app_pod_monitoring" {
  manifest = {
    apiVersion = "monitoring.googleapis.com/v1"
    kind       = "PodMonitoring"
    metadata = {
      name      = "${var.name}-clustering-metrics"
      namespace = kubernetes_namespace.app.metadata.0.name
    }
    spec = {
      selector = {
        matchLabels = local.app_labels
      }
      endpoints = [
        {
          port     = var.config.metrics.port
          path     = var.config.metrics.path
          interval = "30s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "app_horizontal_autoscaler" {
  manifest = {
    apiVersion = "autoscaling/v1"
    kind       = "HorizontalPodAutoscaler"
    metadata = {
      name      = "${var.name}-api-hautoscale"
      namespace = kubernetes_namespace.app.metadata.0.name
    }
    spec = {
      scaleTargetRef = {
        apiVersion = "apps/v1"
        kind       = "Deployment"
        name       = kubernetes_deployment.app.metadata.0.name
      }
      minReplicas                    = var.config.autoscale.min
      maxReplicas                    = var.config.autoscale.max
      targetCPUUtilizationPercentage = var.config.autoscale.cpu_utilization_percentage
    }
  }
}
