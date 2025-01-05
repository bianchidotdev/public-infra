output "bridges_ipv4" {
  value = {
    for k, v in vultr_instance.bridges : k => v.main_ip
  }
}
