#   Import Existing vNET [containing data collection Front End]
data "azurerm_virtual_network" "vnet" {
  resource_group_name = var.rg_aqua_data_collection
  name                = var.vnet_aqua_data_collection
}

#   Create Subnet for Bastion
resource "azurerm_subnet" "bastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg_aqua_data_collection
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/16"]
}

#   Create Subnet for NASA Tools
resource "azurerm_subnet" "nasa_tools_subnet" {
  name                 = "${local.base_name}-tools-subnet-${local.suffix}"
  resource_group_name  = var.rg_aqua_data_collection
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/16"]
  service_endpoints    = ["Microsoft.Storage"]
}
