variable "aks_name" {}
variable "dns_prefix" {}
variable "kubernetes_version" {}

variable "resource_group_name" {}
variable "location" {}

variable "private_subnet_id" {}

variable "system_node_vm_size" {}
variable "system_node_min_count" {}
variable "system_node_max_count" {}

variable "user_node_vm_size" {}
variable "user_node_min_count" {}
variable "user_node_max_count" {}

variable "acr_id" {}

variable "tags" {
  type = map(string)
}
variable "authorized_ip_ranges" {
  description = "Authorized IPs for Kubernetes API Server"
  type        = list(string)
}
