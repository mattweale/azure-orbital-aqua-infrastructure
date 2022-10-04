#   Import Existing Storage Account [containing IPOPP/RT-STPS] for assigning MI RBAC Scope to. The creation of this is a pre-requisite
data "azurerm_storage_account" "sa_aqua_tools" {
  resource_group_name = var.rg_name
  name                = var.AQUA_TOOLS_SA
}

#   Create MI for accessng SA
resource "azurerm_user_assigned_identity" "ua_mi_orbital" {
  resource_group_name = local.rg_name
  location            = local.rg_location
  name                = "${local.base_name}-mi-${local.suffix}"
}

#   Assign MI to the imported Storage Account
resource "azurerm_role_assignment" "ra_mi_sa" {
  scope                = data.azurerm_storage_account.sa_aqua_tools.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.ua_mi_orbital.principal_id
}
