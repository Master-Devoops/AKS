output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "public_subnet_ids" {
  value = {
    for subnet in azurerm_subnet.public :
    subnet.name => subnet.id
  }
}

output "private_subnet_ids" {
  value = {
    for subnet in azurerm_subnet.private :
    subnet.name => subnet.id
  }
}