variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "subnet_id" {
  description = "Private Endpoint subnet id"
  type        = string
}

variable "endpoints" {
  description = <<EOT
Map of resources to create Private Endpoints for.
Example:
{
  acr = {
    resource_id            = module.acr.acr_id
    subresource_name       = "registry"
    private_dns_zone_name  = "privatelink.azurecr.io"
  }
  key_vault = {
    resource_id            = module.key_vault.key_vault_id
    subresource_name       = "vault"
    private_dns_zone_name  = "privatelink.vaultcore.azure.net"
  }
}
EOT
  type = map(object({
    resource_id           = string
    subresource_name      = string
    private_dns_zone_name = string
  }))
}

variable "tags" {
  type = map(string)
}
