# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for the AKS node subnet"
  type        = string
}

variable "bastion_subnet_address_prefix" {
  description = "Address prefix for AzureBastionSubnet (must be /26 or larger)"
  type        = string
}

variable "private_endpoint_subnet_address_prefix" {
  description = "Address prefix for the Private Endpoint subnet"
  type        = string
}

variable "nat_gateway_name" {
  type = string
}

variable "enable_bastion" {
  type    = bool
  default = true
}

variable "bastion_name" {
  type = string
}

# -----------------------------------------------------------------------------
# Log Analytics
# -----------------------------------------------------------------------------
variable "log_analytics_workspace_name" {
  type = string
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------
variable "key_vault_name" {
  type = string
}

variable "key_vault_public_network_access_enabled" {
  type    = bool
  default = false
}

# -----------------------------------------------------------------------------
# ACR
# -----------------------------------------------------------------------------
variable "acr_name" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "acr_public_network_access_enabled" {
  type    = bool
  default = false
}

# -----------------------------------------------------------------------------
# AKS
# -----------------------------------------------------------------------------
variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "private_cluster_enabled" {
  description = "If true, the AKS API server has no public endpoint at all (requires Bastion/VPN to manage)"
  type        = bool
  default     = false
}

variable "system_node_vm_size" {
  type = string
}

variable "system_node_min_count" {
  type = string
}

variable "system_node_max_count" {
  type = string
}

variable "user_node_vm_size" {
  type = string
}

variable "user_node_min_count" {
  type = string
}

variable "user_node_max_count" {
  type = string
}

variable "authorized_ip_ranges" {
  description = "Public IPs allowed to access the AKS API Server"
  type        = list(string)
}
