resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku           = var.acr_sku
  admin_enabled = false

  # Locked to Private Endpoint access only once validated; toggled via
  # public_network_access_enabled for initial bootstrap/CI convenience.
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = true

  dynamic "network_rule_set" {
    for_each = var.acr_sku == "Premium" ? [1] : []
    content {
      default_action = "Deny"
    }
  }

  tags = var.tags
}
