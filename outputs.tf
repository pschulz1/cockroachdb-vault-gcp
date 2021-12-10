output "crdb_console" {
  value = module.common.lb_ip
}

output "test" {
  value = module.node1.node_id
}
// node1_id = module.node1.node_id
// node2_id = module.node2.node_id
// node3_id = module.node3.node_id