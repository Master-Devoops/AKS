module "resource_group" {
  source = "./modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "virtual_network" {
  source = "./modules/virtual-network"

  resource_group_name = module.resource_group.resource_group_name
  location            = var.location

  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  tags       = var.tags
  depends_on = [module.resource_group]
}

module "acr" {
  source = "./modules/acr"

  acr_name            = var.acr_name
  acr_sku             = var.acr_sku
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  tags                = var.tags
  depends_on          = [module.virtual_network]
}

module "aks" {
  source = "./modules/aks"

  aks_name           = var.aks_name
  dns_prefix         = var.dns_prefix
  kubernetes_version = var.kubernetes_version

  resource_group_name = module.resource_group.resource_group_name
  location            = var.location

  private_subnet_id = module.virtual_network.private_subnet_ids["softradix-aks-private-subnet-01"]

  system_node_vm_size   = var.system_node_vm_size
  system_node_min_count = var.system_node_min_count
  system_node_max_count = var.system_node_max_count

  user_node_vm_size   = var.user_node_vm_size
  user_node_min_count = var.user_node_min_count
  user_node_max_count = var.user_node_max_count

  acr_id = module.acr.acr_id

  tags = var.tags

  depends_on = [module.acr]
}
