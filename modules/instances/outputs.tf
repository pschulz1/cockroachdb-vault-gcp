output "node_ip_addr" {
  value       = google_compute_instance.node.network_interface.0.access_config.0.nat_ip
  description = "The puplic IP address of the node"
}
output "node_id" {
  value       = google_compute_instance.node.self_link
  description = "The ID of the GCE instance"
}


