variable "key_vault_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "public_network_access_enabled" {
  description = "Set to false once Private Endpoint access is validated end-to-end"
  type        = bool
  default     = false
}

variable "tags" {
  type = map(string)
}
