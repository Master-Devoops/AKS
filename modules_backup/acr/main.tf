resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku           = var.acr_sku
  admin_enabled = false

  public_network_access_enabled = true
  zone_redundancy_enabled       = true

  tags = var.tags
}
