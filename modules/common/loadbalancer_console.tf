resource "google_compute_forwarding_rule" "console" {
  name            = "crdb-lb-console"
  region          = var.region
  ports      = ["8080"]
  backend_service = google_compute_region_backend_service.main.id
}

resource "google_compute_region_health_check" "console" {
  name               = "crdb-check-console"
  check_interval_sec = 10
  timeout_sec        = 1
  region             = var.region

  tcp_health_check {
    port = "8080"
  }
}