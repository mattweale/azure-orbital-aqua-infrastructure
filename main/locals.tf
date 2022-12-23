resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

resource "random_string" "prefix" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

locals {
  base_name                 = "aqua"
  suffix                    = random_string.suffix.result
  prefix                    = random_string.prefix.result
  rg_name                   = data.azurerm_storage_account.sa_aqua_tools.name
  rg_location               = data.azurerm_storage_account.sa_aqua_tools.location
  rg_aqua_processing_name   = data.azurerm_resource_group.rg_aqua_data_collection.name
  rg_aqua_processing_loc    = data.azurerm_resource_group.rg_aqua_data_collection.location
  vnet_aqua_processing_name = data.azurerm_virtual_network.vnet.name
  vnet_aqua_processing_id   = data.azurerm_virtual_network.vnet.id
  sa_data_collection_name   = data.azurerm_storage_account.sa_data_collection.name
  nasa_tools_subnet_id      = azurerm_subnet.nasa_tools_subnet.id
}
