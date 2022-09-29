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
  base_name               = "aqua"
  suffix                  = random_string.suffix.result
  prefix                  = random_string.prefix.result
  rg_name                 = azurerm_resource_group.orbital_aqua_rg.name
  rg_location             = azurerm_resource_group.orbital_aqua_rg.location
  subnet_address_prefixes = cidrsubnets(var.virtual_network_address_space, 8, 8, 8)
  rg_network_name         = azurerm_resource_group.orbital_aqua_rg.name
  rg_network_location     = azurerm_resource_group.orbital_aqua_rg.location
  private_vm_subnet_id    = azurerm_subnet.private_vm_subnet.id
  orbital_subnet_id       = azurerm_subnet.orbital_subnet.id
  aqua_tools_share        = data.azurerm_storage_account.sa_aqua_tools.name
  aqua_nfs_share          = azurerm_storage_account.sa_aqua_common.name
  bastion_name            = azurerm_bastion_host.bastion.name
  data_collection_vm_name = azurerm_linux_virtual_machine.vm_orbital_data_collection.name
  data_collection_vm_id   = azurerm_linux_virtual_machine.vm_orbital_data_collection.id
}
