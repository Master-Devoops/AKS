output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "resource_group_id" {
  value = module.resource_group.resource_group_id
}

output "vnet_id" {
  value = module.virtual_network.vnet_id
}

output "aks_subnet_id" {
  value = module.virtual_network.aks_subnet_id
}

output "nat_gateway_public_ip" {
  value = module.nat_gateway.public_ip_address
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

output "aks_name" {
  value = module.aks.aks_name
}

output "aks_fqdn" {
  value = module.aks.fqdn
}

output "aks_oidc_issuer_url" {
  value = module.aks.oidc_issuer_url
}

output "aks_node_resource_group" {
  value = module.aks.node_resource_group
}

output "bastion_fqdn" {
  value = module.bastion.bastion_fqdn
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.workspace_id
}

output "get_credentials_command" {
  description = "Run this after apply to configure kubectl"
  value       = "az aks get-credentials --resource-group ${module.resource_group.resource_group_name} --name ${module.aks.aks_name} --overwrite-existing"
}
