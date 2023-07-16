output "vpc" {
  value = {
    id           = google_compute_network.vpc.id
    gateway_ipv4 = google_compute_network.vpc.gateway_ipv4
  }
}

output "subnet" {
  value = {
    id              = google_compute_subnetwork.subnet.id
    gateway_address = google_compute_subnetwork.subnet.gateway_address
  }
}

output "docker_repositories" {
  value = {
    for repo in google_artifact_registry_repository.app : repo.name => repo.id
  }
}

output "gke" {
  value = {
    id       = google_container_cluster.gke.id
    name     = google_container_cluster.gke.name
    location = google_container_cluster.gke.location
    endpoint = google_container_cluster.gke.endpoint
  }
}
