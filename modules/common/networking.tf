resource "google_compute_network" "main" {
  name                    = "crdb-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "crdb-subnetwork"
  ip_cidr_range = "192.168.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id
}


resource "google_compute_firewall" "main" {
  name      = "l4-fw-ssh-console-gossip"
  direction = "INGRESS"
  network   = google_compute_network.main.id
  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "26257"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["crdb"]
}