resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = [local.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "vm" {
  name                 = local.vm_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = [local.vm_subnet_address_prefix]
}

resource "azurerm_subnet" "build" {
  name                 = local.build_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = [local.build_subnet_address_prefix]
}