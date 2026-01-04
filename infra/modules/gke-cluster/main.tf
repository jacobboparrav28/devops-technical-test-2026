resource "google_container_cluster" "container_cluster" {
  name = var.cluster_name
  location = var.region
  project = var.project_id

  network = var.network
  subnetwork = var.subnetwork
  enable_autopilot = true

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
}




// Manual setup
/* resource "google_container_cluster" "container_cluster" {
    name = var.cluster_name
    location = var.region
    project = var.project_id

    network = var.network
    subnetwork = var.subnetwork

    remove_default_node_pool = true
    initial_node_count = 1

    logging_service = "logging.googleapis.com/kubernetes"
    monitoring_service = "monitoring.googleapis.com/kubernetes"

    // Basic security settings
    master_auth {
      client_certificate_config {
        issue_client_certificate = false
      }
    }

    // shielded nodes
    // each node will have its own settings, but we can set defaults here
    node_config {
        shielded_instance_config {
            enable_secure_boot = true
            enable_integrity_monitoring = true
        }
    }
} */