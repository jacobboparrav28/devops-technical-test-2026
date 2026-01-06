resource "google_container_node_pool" "this" {
  name       = var.node_pool_name
  cluster    = var.cluster_name
  location   = var.region
  project    = var.project_id

  node_count = var.node_count
  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb

    disk_type = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      pool = var.node_pool_name
    }
  }
}