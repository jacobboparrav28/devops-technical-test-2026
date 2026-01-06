provider "google" {
    project = var.project_id
    region = var.region
}

module "network" {
  source = "../../modules/network"

  project_id   = var.project_id
  network_name = "prod-vpc" # Cambiamos el nombre para diferenciarlo
  region       = var.region
  subnet_cidr  = "10.20.0.0/16" # Usamos un rango diferente a staging
}

module "gke" {
  source = "../../modules/gke-cluster"

  project_id   = var.project_id
  cluster_name = "prod-cluster"
  region       = var.region

  enable_autopilot = false

  network    = module.network.network_name
  subnetwork = module.network.subnet_name
  
}


module "app_node_pool" {
  source = "../../modules/node-pool"
  
  project_id     = var.project_id
  cluster_name   = module.gke.cluster_name
  region         = var.region

  node_pool_name = "prod-pool"
  machine_type   = "e2-medium"
  
  # CONFIGURACIÓN PARA 300 GB TOTALES
  node_count     = 1   # 3 Máquinas
  disk_size_gb   = 50 # 100 GB cada una
}
