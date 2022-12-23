#   Create Public IP
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${local.base_name}-bastion-pip-${local.suffix}"
  resource_group_name = local.rg_aqua_processing_name
  location            = local.rg_aqua_processing_loc
  allocation_method   = "Static"
  sku                 = "Standard"
}

#   Create Bastion
resource "azurerm_bastion_host" "bastion" {
  name                = "${local.base_name}-bastion-${local.suffix}"
  resource_group_name = local.rg_aqua_processing_name
  location            = local.rg_aqua_processing_loc
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastionsubnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
