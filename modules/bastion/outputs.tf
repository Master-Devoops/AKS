output "bastion_id" {
  value = var.enable_bastion ? azurerm_bastion_host.this[0].id : null
}

output "bastion_fqdn" {
  value = var.enable_bastion ? azurerm_bastion_host.this[0].dns_name : null
}
