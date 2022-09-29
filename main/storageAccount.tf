#   Create Storage Account with HNS and NFS Enabled for mounting across Aqua VMs
resource "azurerm_storage_account" "sa_aqua_common" {
  name                = "${local.base_name}sa${local.suffix}"
  resource_group_name = local.rg_name

  location                 = local.rg_location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"

  is_hns_enabled = true
  nfsv3_enabled  = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = [var.home_ip]
    virtual_network_subnet_ids = [azurerm_subnet.private_vm_subnet.id]
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
