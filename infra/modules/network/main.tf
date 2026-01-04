resource "google_compute_network" "vpc_network" {
    name = var.network_name
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
    name          = "${var.network_name}-subnet"
    ip_cidr_range = var.subnet_cidr
    region        = var.region
    network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow-internal" {
    name = "${var.network_name}-allow-internal"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = "tcp"
        ports    = ["0-65535"]
    }

    allow {
        protocol = "udp"
        ports    = ["0-65535"]
    }

    source_ranges = [var.subnet_cidr]
}

// Allow communication between nodes.
// Internal K8s traffic.