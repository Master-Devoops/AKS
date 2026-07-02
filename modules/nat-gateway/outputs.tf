output "nat_gateway_id" {
  value = azurerm_nat_gateway.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.nat.ip_address
}
