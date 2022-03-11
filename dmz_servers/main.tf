data "azurerm_resource_group" "rg" {
  name = var.my_resource_gr
}

# Get vnet
data "azurerm_virtual_network" "vnet" {
  name                = var.my_vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = "subnet_dmz1"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "nic_dmz_server_a" {
    name                = "nic_dmz_server_a"
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name
    enable_ip_forwarding = "true"
	ip_configuration {
        name                          = "gwexternalConfiguration"
        subnet_id                     = data.azurerm_subnet.subnet.id
        private_ip_address_allocation = "Static"
		private_ip_address = "10.95.11.35"
        primary = true
		#public_ip_address_id = "${azurerm_public_ip.gwpublicip.id}"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = data.azurerm_resource_group.rg.name
    }
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = data.azurerm_resource_group.rg.name
    location                    = data.azurerm_resource_group.rg.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

resource "azurerm_virtual_machine" "ubuntujumphost" {
    name                  = "dmz_server_a"
    location              = data.azurerm_resource_group.rg.location
    resource_group_name   = data.azurerm_resource_group.rg.name
    network_interface_ids = ["${azurerm_network_interface.nic_dmz_server_a.id}"]
    vm_size               = "Standard_B1s"

    storage_os_disk {
        name              = "server_a_disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "dmz1"
        admin_username = "azureuser"
        admin_password = "Cpwins1!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

}

