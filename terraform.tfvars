resource_group_name = "Softradix-AKS-RG"
location            = "East US"

tags = {
  Environment = "Development"
  Owner       = "Yogesh"
  Project     = "Terraform"
}

vnet_name = "softradix-aks-vnet"

vnet_address_space = [
  "10.0.0.0/16"
]

public_subnets = {
  "softradix-aks-public-subnet-01" = "10.0.1.0/24"
  "softradix-aks-public-subnet-02" = "10.0.2.0/24"
  "softradix-aks-public-subnet-03" = "10.0.3.0/24"
}

private_subnets = {
  "softradix-aks-private-subnet-01" = "10.0.10.0/24"
  "softradix-aks-private-subnet-02" = "10.0.20.0/24"
  "softradix-aks-private-subnet-03" = "10.0.30.0/24"
}

acr_name = "softradixaksacr"
acr_sku  = "Premium"

aks_name   = "softradix-aks-cluster"
dns_prefix = "softradix-aks"

kubernetes_version = "1.36.1"

system_node_vm_size   = "Standard_D2s_v7"
system_node_min_count = 1
system_node_max_count = 1

user_node_vm_size   = "Standard_D2s_v7"
user_node_min_count = 1
user_node_max_count = 1
