#   Create vNET
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.base_name}-vnet-${local.suffix}"
  location            = local.rg_network_location
  resource_group_name = local.rg_network_name
  address_space       = [var.virtual_network_address_space]
  tags                = var.tags
}

#   Create Subnet for Bastion
resource "azurerm_subnet" "bastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = local.rg_network_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.subnet_address_prefixes[0]]
}

#   Create Subnet for Private AQUA VM Services
resource "azurerm_subnet" "private_vm_subnet" {
  name                 = "${local.base_name}-private-vm-subnet-${local.suffix}"
  resource_group_name  = local.rg_network_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.subnet_address_prefixes[1]]
  service_endpoints    = ["Microsoft.Storage"]
}

#   Create Subnet for Azure Orbital Vnet Integration
resource "azurerm_subnet" "orbital_subnet" {
  name                 = "${local.base_name}-orbital-subnet-${local.suffix}"
  resource_group_name  = local.rg_network_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.subnet_address_prefixes[2]]
  delegation {
    name = "orbital-payload-delegation"

    service_delegation {
      name    = "Microsoft.Orbital/orbitalGateways"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
