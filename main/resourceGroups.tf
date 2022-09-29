resource "azurerm_resource_group" "orbital_aqua_rg" {
  name     = "${local.base_name}-rg-${local.suffix}"
  location = var.azure_region
}
