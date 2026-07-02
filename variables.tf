variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "public_subnets" {
  type = map(string)
}

variable "private_subnets" {
  type = map(string)
}

variable "acr_name" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "kubernetes_version" {
  type = string
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
