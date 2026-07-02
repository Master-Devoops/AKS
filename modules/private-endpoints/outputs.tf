output "private_endpoint_ids" {
  value = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_ips" {
  value = {
    for k, v in azurerm_private_endpoint.this :
    k => v.private_service_connection[0].private_ip_address
  }
}
