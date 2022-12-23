#   Create PIP and NIC for RTSTPS VM
resource "azurerm_public_ip" "pip_orbital_rtstps" {
  name                = "${local.base_name}-pip-rtstps-vm-${local.suffix}"
  resource_group_name = local.rg_aqua_processing_name
  location            = local.rg_aqua_processing_loc
  allocation_method   = "Static"
  domain_name_label   = "aqua-rtstps-vm"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic_orbital_data_rtstps" {
  name                = "${local.base_name}-nic-rtstps-${local.suffix}"
  resource_group_name = local.rg_aqua_processing_name
  location            = local.rg_aqua_processing_loc
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.nasa_tools_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_orbital_rtstps.id
  }
}

#   Create Linux VM for RTSTPS VM
resource "azurerm_linux_virtual_machine" "vm_orbital_rtstps" {
  name                            = "vm-rtstps"
  resource_group_name             = local.rg_aqua_processing_name
  location                        = local.rg_aqua_processing_loc
  size                            = var.vmsize
  admin_username                  = "adminuser"
  admin_password                  = "Pa55w0rd123!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_orbital_data_rtstps.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 100
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
    version   = "latest"
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ua_mi_orbital.id]
  }
}
#   Create Data Disk and Attach to VM
resource "azurerm_managed_disk" "data_disk_orbital_rtstps_vm" {
  name                 = "${local.base_name}-data-disk-rtstps-vm-${local.suffix}"
  resource_group_name  = local.rg_aqua_processing_name
  location             = local.rg_aqua_processing_loc
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_orbital_rtstps_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk_orbital_rtstps_vm.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm_orbital_rtstps.id
  lun                = "10"
  caching            = "ReadWrite"
}
#   Custom Script Extension to Configure VM
resource "azurerm_virtual_machine_extension" "cse_vm_orbital_rtstps_config" {
  name                       = "cse_orbital-rtstps-config"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm_orbital_rtstps.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true
  depends_on                 = [azurerm_virtual_machine_data_disk_attachment.data_disk_orbital_rtstps_attach]
  timeouts {
    create = "30m"
  }
  settings = <<SETTINGS
    {
        "commandToExecute":"export AQUA_NFS_SHARE=${azurerm_storage_account.sa_aqua_common.name} && export AQUA_MI_ID=${azurerm_user_assigned_identity.ua_mi_orbital.client_id} && export AQUA_TOOLS_SA=${data.azurerm_storage_account.sa_aqua_tools.name} && ./main_rtstps.sh > ./logfile.txt exit 0",
        "fileUris":["https://raw.githubusercontent.com/mattweale/azure-orbital-aqua-infrastructure/main/vm_configuration/mount_data_drive.sh",
                    "https://raw.githubusercontent.com/mattweale/azure-orbital-aqua-infrastructure/main/vm_configuration/mount_container.sh",
                    "https://raw.githubusercontent.com/mattweale/azure-orbital-aqua-infrastructure/main/vm_configuration/main_rtstps.sh",
                    "https://raw.githubusercontent.com/mattweale/azure-orbital-aqua-infrastructure/main/vm_configuration/install_rtstps.sh",
                    "https://github.com/mattweale/azure-orbital-aqua-infrastructure/blob/main/vm_configuration/aqua_datachecker.py"]
    }
SETTINGS
  tags     = var.tags
}
