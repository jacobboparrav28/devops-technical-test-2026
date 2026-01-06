resource "google_container_cluster" "container_cluster" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  deletion_protection = false
  enable_autopilot = var.enable_autopilot ? true : null

  remove_default_node_pool = var.enable_autopilot ? null : true
  initial_node_count       = var.enable_autopilot ? null : 1

  network    = var.network
  subnetwork = var.subnetwork

  dynamic "node_config" {
    for_each = var.enable_autopilot ? [] : [1]
    content {
      disk_size_gb = 50
      disk_type = "pd-standard"
    }
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/14"
    services_ipv4_cidr_block = "/20"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}
