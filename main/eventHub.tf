#   Create Event Hub and Namespace
resource "azurerm_eventhub_namespace" "eh-orbital-ns" {
  name                = "${local.base_name}-eh-ns-${local.suffix}"
  location            = local.rg_network_location
  resource_group_name = local.rg_network_name
  sku                 = "Standard"
  capacity            = 1

  tags = var.tags
}

resource "azurerm_eventhub" "eh-orbital" {
  name                = "${local.base_name}-eh-${local.suffix}"
  namespace_name      = azurerm_eventhub_namespace.eh-orbital-ns.name
  resource_group_name = local.rg_network_name
  partition_count     = 2
  message_retention   = 1
}
