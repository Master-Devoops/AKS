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

  tags = var.tags
}