#   Import Existing Storage Account [containing IPOPP/RT-STPS] for assigning MI RBAC Scope to. The creation of this is a pre-requisite
data "azurerm_storage_account" "sa_aqua_tools" {
  resource_group_name = var.AQUA_TOOLS_RG
  name                = var.AQUA_TOOLS_SA
}

# Add Network ACL to Storage Account to allow access from toolings VMs - Need to finish this!
#resource "azurerm_storage_account_network_rules" "sa_tools_nacl" {
#  storage_account_id = data.azurerm_storage_account.sa_aqua_tools.id
#  default_action             = "Allow"
#  ip_rules                   = [azurerm_public_ip.pip_orbital_rtstps.ip_address]
#  virtual_network_subnet_ids = [azurerm_subnet.nasa_tools_subnet.id]
#  bypass                     = ["AzureServices"]
#}

#   Import Existing Storage Account [for data collection] Not HNS/NFS Enabled so need to mount with Blobfuse, WIP!
data "azurerm_storage_account" "sa_data_collection" {
  resource_group_name = var.rg_aqua_data_collection
  name                = var.sa_data_collection
}

#   Create Storage Account with HNS and NFS Enabled for mounting across Aqua VMs
resource "azurerm_storage_account" "sa_aqua_common" {
  name                     = "${local.base_name}toolssa${local.suffix}"
  location                 = local.rg_aqua_processing_loc
  resource_group_name      = local.rg_aqua_processing_name
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"

  is_hns_enabled = true
  nfsv3_enabled  = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = [var.BUILD_AGENT_IP]
    virtual_network_subnet_ids = [local.nasa_tools_subnet_id]
  }

  tags = var.tags
}

resource "azurerm_storage_container" "raw_container" {
  name                 = "raw-data"
  storage_account_name = azurerm_storage_account.sa_aqua_common.name
}

resource "azurerm_storage_container" "rt-stps_container" {
  name                 = "rt-stps"
  storage_account_name = azurerm_storage_account.sa_aqua_common.name
}

resource "azurerm_storage_container" "ipopp_container" {
  name                 = "ipopp"
  storage_account_name = azurerm_storage_account.sa_aqua_common.name
}

resource "azurerm_storage_container" "shared_container" {
  name                 = "shared"
  storage_account_name = azurerm_storage_account.sa_aqua_common.name
}

# Create Container in the tcp-to-blob Storage Account
resource "azurerm_storage_container" "shared" {
  name                 = "shared"
  storage_account_name = data.azurerm_storage_account.sa_data_collection.name
}
