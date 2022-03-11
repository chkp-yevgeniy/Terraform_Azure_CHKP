
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]    
  location            = data.azurerm_resource_group.rg.location
}