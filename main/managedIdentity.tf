#   Create MI for accessing SA with NASA Tools and SA with Data
resource "azurerm_user_assigned_identity" "ua_mi_orbital" {
  resource_group_name = local.rg_aqua_processing_name
  location            = local.rg_aqua_processing_loc
  name                = "${local.base_name}-mi-${local.suffix}"
}

#   Assign MI to the imported Storage Account for Access to the NASA Tools
resource "azurerm_role_assignment" "ra_mi_tools_sa" {
  scope                = data.azurerm_storage_account.sa_aqua_tools.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.ua_mi_orbital.principal_id
}

#   Assign MI to the imported Storage Account for Access to AQUA Data
resource "azurerm_role_assignment" "ra_mi_data_sa" {
  scope                = data.azurerm_storage_account.sa_data_collection.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.ua_mi_orbital.principal_id
}
