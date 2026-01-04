provider "google" {
    project = var.project_id
    region = var.region
}
// First network then GKE cluster
module "network" {
  source = "../../modules/network"

  project_id   = var.project_id
  network_name = "staging-vpc"
  region       = var.region
  subnet_cidr  = "10.10.0.0/16"
}

module "gke" {
  source = "../../modules/gke-cluster"

  project_id   = var.project_id
  cluster_name = "staging-cluster"
  region       = var.region

  network    = module.network.network_name
  subnetwork = module.network.subnet_name
}

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id = var.project_id
  region     = var.region
  repo_name  = var.artifact_registry_repo
}

/* module "app_node_pool" {
  source = "../../modules/node-pool"

  project_id     = var.project_id
  cluster_name   = module.gke.cluster_name
  region         = var.region

  node_pool_name = "app-pool"
  machine_type   = "e2-medium"
  node_count     = 1
}
 */