output "lb_ip" {
  value = google_compute_forwarding_rule.console.ip_address
}
output "network" {
  value = google_compute_network.main.id
}
output "subnetwork" {
  value = google_compute_subnetwork.main.id
}
output "service_account_email" {
  value = google_service_account.crdb.email
}