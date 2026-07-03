# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = var.vnet_address_space

  tags = var.tags
}

# -----------------------------------------------------------------------------
# AKS Node Subnet
# Hosts the AKS system + user node pools. No public IPs are ever assigned
# here; outbound internet access flows exclusively through the NAT Gateway
# associated with this subnet (see modules/nat-gateway).
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "aks_nodes" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.aks_subnet_address_prefix]
}

# -----------------------------------------------------------------------------
# AzureBastionSubnet
# Name is fixed by Azure - Bastion will not deploy into a subnet with any
# other name. Minimum size is /26.
#
# NOTE: explicit depends_on below is intentional. Azure holds an implicit
# lock on the parent VNet while writing a subnet; creating multiple subnets
# on a freshly-created VNet in parallel (Terraform's default behaviour)
# routinely produces transient "404 Not Found" / "AnotherOperationInProgress"
# errors from ARM. Chaining the subnets forces them to be created serially.
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.bastion_subnet_address_prefix]

  depends_on = [azurerm_subnet.aks_nodes]
}

# -----------------------------------------------------------------------------
# Private Endpoint Subnet
# Hosts Private Endpoints for ACR, Key Vault and (optionally) Storage.
# Network policies must be disabled for Private Endpoints to be placed here.
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name

  address_prefixes = [var.private_endpoint_subnet_address_prefix]

  private_endpoint_network_policies = "Disabled"

  depends_on = [azurerm_subnet.bastion]
}

# -----------------------------------------------------------------------------
# Network Security Groups
# -----------------------------------------------------------------------------

# AKS node subnet NSG - deny inbound from Internet, allow only what AKS/LB
# and intra-VNet traffic require. Egress is open (outbound egress control is
# handled by the NAT Gateway + firewall/UDR if added later); inbound is
# locked down.
resource "azurerm_network_security_group" "aks_nodes" {
  name                = "${var.aks_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternetInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_nodes" {
  subnet_id                 = azurerm_subnet.aks_nodes.id
  network_security_group_id = azurerm_network_security_group.aks_nodes.id
}

# Private endpoint subnet NSG - internal traffic only.
resource "azurerm_network_security_group" "private_endpoints" {
  name                = "${var.private_endpoint_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyInternetInBound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

# NOTE: AzureBastionSubnet intentionally has NO custom NSG attached here by
# default because Bastion requires a very specific, exact set of rules
# (documented by Microsoft) or the service silently breaks. The dedicated
# rules are created in modules/bastion and associated there so they live
# next to the Bastion host they protect.
