resource "google_compute_forwarding_rule" "sql" {
  name            = "crdb-lb-sql"
  region          = var.region
  port_range      = 26257
  backend_service = google_compute_region_backend_service.main.id
}

resource "google_compute_region_health_check" "sql" {
  name               = "crdb-check-sql"
  check_interval_sec = 10
  timeout_sec        = 1
  region             = var.region

  tcp_health_check {
    port = "26257"
  }
}