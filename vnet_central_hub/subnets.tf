resource "azurerm_subnet" "External_subnet"  {
  name           = var.subnet_external_name
  resource_group_name  = var.my_resource_gr
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.95.0.0/24"]
}

resource "azurerm_subnet" "Internal_subnet"   {
  name           = var.subnet_internal_name
  resource_group_name  = var.my_resource_gr
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.95.1.0/24"]
}

resource "azurerm_subnet" "subnet_dmz1"  {
  name           = var.subnet_dmz1_name
  resource_group_name  = var.my_resource_gr
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.95.11.0/24"]
}
  
  
