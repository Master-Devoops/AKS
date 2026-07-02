variable "bastion_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "bastion_subnet_id" {
  type = string
}

variable "enable_bastion" {
  description = "Whether to deploy Azure Bastion for secure administrative access"
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
}
