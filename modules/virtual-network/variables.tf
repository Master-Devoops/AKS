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

variable "public_subnets" {
  type = map(string)
}

variable "private_subnets" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}