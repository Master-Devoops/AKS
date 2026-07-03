resource_group_name = "Softradix-AKS-RG"
location             = "East US 2"

tags = {
  Environment = "Production"
  Owner       = "Yogesh"
  Project     = "Terraform"
}

# ---------------------------------------------------------------------------
# Networking - single VNet, three private subnets, no public subnets.
# ---------------------------------------------------------------------------
vnet_name          = "softradix-aks-vnet"
vnet_address_space = ["10.0.0.0/16"]

aks_subnet_address_prefix              = "10.0.1.0/24"
bastion_subnet_address_prefix          = "10.0.2.0/26"
private_endpoint_subnet_address_prefix = "10.0.3.0/24"

nat_gateway_name = "softradix-aks-natgw"

enable_bastion = true
bastion_name   = "softradix-aks-bastion"

# ---------------------------------------------------------------------------
# Log Analytics
# ---------------------------------------------------------------------------
log_analytics_workspace_name = "softradix-aks-law"

# ---------------------------------------------------------------------------
# Key Vault
# ---------------------------------------------------------------------------
key_vault_name                          = "softradix-aks-kv"
key_vault_public_network_access_enabled = false

# ---------------------------------------------------------------------------
# ACR
# ---------------------------------------------------------------------------
acr_name                           = "softradixaksacr"
acr_sku                            = "Premium"
acr_public_network_access_enabled  = false

# ---------------------------------------------------------------------------
# AKS
# ---------------------------------------------------------------------------
aks_name   = "softradix-aks-cluster"
dns_prefix = "softradix-aks"

kubernetes_version = "1.30.3"

private_cluster_enabled = false

system_node_vm_size   = "Standard_D2s_v5"
system_node_min_count = 1
system_node_max_count = 3

user_node_vm_size   = "Standard_D2s_v5"
user_node_min_count = 1
user_node_max_count = 5

# Replace with YOUR public IP(s) - this is the only place allowed to reach
# the AKS API server. Find yours with `curl ifconfig.me`.
authorized_ip_ranges = ["61.247.230.182/32"]
