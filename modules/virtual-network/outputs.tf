output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_nodes.id
}

output "aks_subnet_name" {
  value = azurerm_subnet.aks_nodes.name
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "private_endpoint_subnet_name" {
  value = azurerm_subnet.private_endpoints.name
}
