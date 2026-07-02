data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  # RBAC instead of legacy access policies
  rbac_authorization_enabled = true

  purge_protection_enabled  = true
  soft_delete_retention_days = 90

  # Locked down to Private Endpoint access only; toggle for bootstrap/CI.
  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}
