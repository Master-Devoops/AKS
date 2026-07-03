module "resource_group" {
  source = "./modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Brand-new Resource Groups aren't always immediately consistent across every
# ARM read replica. Firing several independent modules at a freshly-created
# RG in parallel (the default Terraform behaviour) can produce transient
# "404 Not Found" / "provider produced inconsistent result" errors on the
# very first apply. A short, one-time propagation delay avoids that without
# permanently serializing every subsequent apply (the sleep is only ever
# created once and then cached in state).
# -----------------------------------------------------------------------------
resource "time_sleep" "resource_group_propagation" {
  depends_on      = [module.resource_group]
  create_duration = "30s"
}

module "virtual_network" {
  source = "./modules/virtual-network"

  resource_group_name = module.resource_group.resource_group_name
  location            = var.location

  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space

  aks_subnet_address_prefix              = var.aks_subnet_address_prefix
  bastion_subnet_address_prefix          = var.bastion_subnet_address_prefix
  private_endpoint_subnet_address_prefix = var.private_endpoint_subnet_address_prefix

  tags       = var.tags
  depends_on = [time_sleep.resource_group_propagation]
}

module "nat_gateway" {
  source = "./modules/nat-gateway"

  nat_gateway_name    = var.nat_gateway_name
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  aks_subnet_id       = module.virtual_network.aks_subnet_id

  tags = var.tags

  depends_on = [module.virtual_network]
}

module "log_analytics" {
  source = "./modules/log-analytics"

  workspace_name      = var.log_analytics_workspace_name
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location

  tags = var.tags

  depends_on = [time_sleep.resource_group_propagation]
}

module "bastion" {
  source = "./modules/bastion"

  bastion_name        = var.bastion_name
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  bastion_subnet_id   = module.virtual_network.bastion_subnet_id
  enable_bastion      = var.enable_bastion

  tags = var.tags

  depends_on = [module.virtual_network]
}

module "key_vault" {
  source = "./modules/key-vault"

  key_vault_name                = var.key_vault_name
  resource_group_name           = module.resource_group.resource_group_name
  location                      = var.location
  public_network_access_enabled = var.key_vault_public_network_access_enabled

  tags = var.tags

  depends_on = [time_sleep.resource_group_propagation]
}

module "acr" {
  source = "./modules/acr"

  acr_name                      = var.acr_name
  acr_sku                       = var.acr_sku
  resource_group_name           = module.resource_group.resource_group_name
  location                      = var.location
  public_network_access_enabled = var.acr_public_network_access_enabled
  tags                          = var.tags
  depends_on                    = [module.virtual_network]
}

# -----------------------------------------------------------------------------
# Private Endpoints for ACR + Key Vault (Storage can be added the same way
# once a storage account module/resource exists - see README "Private
# Endpoint Flow" for the pattern).
# -----------------------------------------------------------------------------
module "private_endpoints" {
  source = "./modules/private-endpoints"

  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  vnet_id             = module.virtual_network.vnet_id
  subnet_id           = module.virtual_network.private_endpoint_subnet_id

  endpoints = {
    acr = {
      resource_id           = module.acr.acr_id
      subresource_name      = "registry"
      private_dns_zone_name = "privatelink.azurecr.io"
    }
    key_vault = {
      resource_id           = module.key_vault.key_vault_id
      subresource_name      = "vault"
      private_dns_zone_name = "privatelink.vaultcore.azure.net"
    }
  }

  tags = var.tags
}

module "aks" {
  source = "./modules/aks"

  aks_name           = var.aks_name
  dns_prefix         = var.dns_prefix
  kubernetes_version = var.kubernetes_version

  resource_group_name = module.resource_group.resource_group_name
  location            = var.location

  aks_subnet_id           = module.virtual_network.aks_subnet_id
  private_cluster_enabled = var.private_cluster_enabled

  system_node_vm_size   = var.system_node_vm_size
  system_node_min_count = var.system_node_min_count
  system_node_max_count = var.system_node_max_count

  user_node_vm_size   = var.user_node_vm_size
  user_node_min_count = var.user_node_min_count
  user_node_max_count = var.user_node_max_count

  authorized_ip_ranges = concat(
    var.authorized_ip_ranges,
    ["${module.nat_gateway.public_ip_address}/32"]
  )

  acr_id                     = module.acr.acr_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  nat_gateway_association_id = module.nat_gateway.nat_gateway_id

  tags = var.tags

  depends_on = [module.acr, module.nat_gateway, module.log_analytics]
}

# -----------------------------------------------------------------------------
# AKS Kubelet Identity -> ACR AcrPull role assignment.
# Fully automatic - nobody ever runs `az role assignment create` by hand.
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id

  depends_on = [module.aks]
}
