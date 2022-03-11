
resource "azurerm_route_table" "rt_dmz1" {
  name                = "rt_dmz1"  
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = var.my_resource_gr
  route {
    name           = "internal"
    address_prefix = "10.95.0.0/20"
    next_hop_type  = "vnetlocal"
  }
  route {
    # Default route to CP GW
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
	next_hop_in_ip_address = "10.95.0.10"
  }
}

resource "azurerm_subnet_route_table_association" "dmt1_rt_association" {
      subnet_id      = azurerm_subnet.subnet_dmz1.id
      route_table_id = azurerm_route_table.rt_dmz1.id
}