#   Create PIP and NIC for Satellite Data Collection VM
resource "azurerm_public_ip" "pip_orbital_data_collection" {
  name                = "${local.base_name}-pip-data-collection-vm-${local.suffix}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  zones               = [2]
  allocation_method   = "Static"
  domain_name_label   = "aqua-data-collection-vm"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic_orbital_data_collection" {
  name                = "${local.base_name}-nic-data-collection-vm-${local.suffix}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_orbital_data_collection.id
  }
}

#   Create Linux VM for Satellite Data Collection Endpoint
resource "azurerm_linux_virtual_machine" "vm_orbital_data_collection" {
  name                            = "vm-orbital-data-collection"
  location                        = local.rg_location
  resource_group_name             = local.rg_name
  size                            = var.vmsize
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_orbital_data_collection.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 100
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

#   Create Data Disk and Attach to VM
resource "azurerm_managed_disk" "data_disk_orbital_collection_vm" {
  name                 = "${local.base_name}-data-disk-data-collection-vm-${local.suffix}"
  location             = local.rg_location
  resource_group_name  = local.rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_orbital_collection_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk_orbital_collection_vm.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm_orbital_data_collection.id
  lun                = "10"
  caching            = "ReadWrite"
  depends_on         = [azurerm_linux_virtual_machine.vm_orbital_data_collection]
}

#   Custom Script Extension to Configure VM
resource "azurerm_virtual_machine_extension" "cse_vm_orbital_data_collection_config" {
  name                       = "cse_orbital-data_collection-config"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm_orbital_data_collection.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true
  depends_on                 = [azurerm_virtual_machine_data_disk_attachment.data_disk_orbital_collection_attach]
  settings                   = <<SETTINGS
    { 
        "commandToExecute":"export AQUA_NFS_SHARE=${azurerm_storage_account.sa_aqua_common.name} && ./main_data.sh > ./logfile.txt exit 0",
        "fileUris":["https://raw.githubusercontent.com/mattweale/azure-orbital-infrastructure/main/vm_configuration/mount_data_drive.sh",
                    "https://raw.githubusercontent.com/mattweale/azure-orbital-infrastructure/main/vm_configuration/mount_container.sh",
                    "https://raw.githubusercontent.com/mattweale/azure-orbital-infrastructure/main/vm_configuration/ubuntu_update.sh",
                    "https://raw.githubusercontent.com/mattweale/azure-orbital-infrastructure/main/vm_configuration/main_data.sh"]
    }
SETTINGS
  tags                       = var.tags
}
