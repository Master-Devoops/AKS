variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_name" {
  type    = string
  default = "softradix-aks-node-subnet"
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for the AKS node subnet (nodes only - never public)"
  type        = string
}

variable "bastion_subnet_address_prefix" {
  description = "Address prefix for AzureBastionSubnet. Must be /26 or larger."
  type        = string
}

variable "private_endpoint_subnet_name" {
  type    = string
  default = "softradix-aks-pe-subnet"
}

variable "private_endpoint_subnet_address_prefix" {
  description = "Address prefix for the Private Endpoint subnet (ACR, Key Vault, Storage)"
  type        = string
}

variable "tags" {
  type = map(string)
}
