output "crdb_console" {
  value = "https://${module.common.lb_ip}:8080"
}