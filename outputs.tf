output "crdb_console" {
  value = "${module.common.lb_ip}:8080"
}