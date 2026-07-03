resource "azurerm_kubernetes_cluster" "this" {

  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = var.dns_prefix

  kubernetes_version = var.kubernetes_version

  # Public API Server is disabled from a DNS resolution standpoint by
  # authorized_ip_ranges below; private_cluster_enabled stays false so the
  # API server keeps a public FQDN but is only reachable from the IPs listed
  # in authorized_ip_ranges. Set to true instead if you want the API server
  # to have no public endpoint at all (requires VPN/ExpressRoute/Bastion
  # jump-box connectivity to manage the cluster).
  private_cluster_enabled = var.private_cluster_enabled

  sku_tier = "Standard"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  default_node_pool {

    name = "system"

    vm_size = var.system_node_vm_size

    auto_scaling_enabled = true

    min_count = var.system_node_min_count
    max_count = var.system_node_max_count

    vnet_subnet_id = var.aks_subnet_id

    only_critical_addons_enabled = true

    temporary_name_for_rotation = "sysrotate"

    type = "VirtualMachineScaleSets"

    # zones = ["1","2","3"]
  }

  network_profile {

    network_plugin      = "azure"
    network_plugin_mode = "overlay"

    pod_cidr = "192.168.0.0/16"

    service_cidr = "172.16.0.0/16"

    dns_service_ip = "172.16.0.10"

    load_balancer_sku = "standard"

    # Outbound traffic for every node/pod flows exclusively through the
    # NAT Gateway that is already associated with the AKS node subnet
    # (modules/nat-gateway). Nodes get no public IPs; the standard Load
    # Balancer created below is used only for INBOUND application traffic
    # via the NGINX ingress controller's Service, never for egress.
    outbound_type = "loadBalancer"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  tags = var.tags

  depends_on = [var.nat_gateway_association_id]
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id

  vm_size = var.user_node_vm_size

  auto_scaling_enabled = true

  min_count = var.user_node_min_count
  max_count = var.user_node_max_count

  vnet_subnet_id = var.aks_subnet_id

  mode = "User"

  # zones = ["1", "2", "3"]

  tags = var.tags
}
