resource "google_compute_instance_group" "node1" {
  name        = "crdb-node1"
  description = "CockroachDB cluster nodes"

  instances = [
    var.node1_id,
  ]

  named_port {
    name = "https"
    port = "8080"
  }

  zone = "${var.region}-a"
}

resource "google_compute_instance_group" "node2" {
  name        = "crdb-node2"
  description = "CockroachDB cluster nodes"

  instances = [
    var.node2_id,
  ]

  named_port {
    name = "https"
    port = "8080"
  }

  zone = "${var.region}-b"
}

resource "google_compute_instance_group" "node3" {
  name        = "crdb-node3"
  description = "CockroachDB cluster nodes"

  instances = [
    var.node3_id,
  ]

  named_port {
    name = "https"
    port = "8080"
  }

  zone = "${var.region}-c"
}

resource "google_compute_region_backend_service" "main" {
  name                  = "crdb-backend"
  region                = var.region
  load_balancing_scheme = "EXTERNAL"

  backend {
    group          = google_compute_instance_group.node1.id
    balancing_mode = "CONNECTION"
  }

  backend {
    group          = google_compute_instance_group.node2.id
    balancing_mode = "CONNECTION"
  }

  backend {
    group          = google_compute_instance_group.node3.id
    balancing_mode = "CONNECTION"
  }

  health_checks = [google_compute_region_health_check.console.id]
}