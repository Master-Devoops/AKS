variable "nat_gateway_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_subnet_id" {
  type = string
}

variable "zones" {
  description = "Availability zones for the NAT Gateway and its Public IP"
  type        = list(string)
  default     = ["1"]
}

variable "tags" {
  type = map(string)
}
