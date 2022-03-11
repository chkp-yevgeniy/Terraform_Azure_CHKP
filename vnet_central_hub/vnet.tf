data "azurerm_resource_group" "rg" {
  name = var.my_resource_gr
}

output "rg" {
  value = data.azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.my_vnet_name  
  resource_group_name = var.my_resource_gr    
  location            = data.azurerm_resource_group.rg.location
  address_space       = [var.vnet_cidr]  
}

