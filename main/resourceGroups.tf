#   Import Existing Resource Group [containing data collection Front End]
data "azurerm_resource_group" "rg_aqua_data_collection" {
  name = var.rg_aqua_data_collection
}
