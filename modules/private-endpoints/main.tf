# -----------------------------------------------------------------------------
# Generic Private Endpoint module.
# Accepts a map of "private link enabled" targets (ACR, Key Vault, Storage...)
# and, for each one, creates:
#   - the Private Endpoint itself (in the Private Endpoint subnet)
#   - a Private DNS Zone (if not supplied externally)
#   - a VNet link for that zone
#   - the DNS A-record registration group
# -----------------------------------------------------------------------------

resource "azurerm_private_dns_zone" "this" {
  for_each = var.endpoints

  name                = each.value.private_dns_zone_name
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.endpoints

  name                  = "${each.key}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.endpoints

  name                = "${each.key}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.subresource_name]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${each.key}-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.this[each.key].id]
  }

  tags = var.tags
}
