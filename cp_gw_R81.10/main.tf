# Doesn't work via spectra
## resource "azurerm_marketplace_agreement" "checkpoint" {
##   publisher = "checkpoint"
##   #offer     = "check-point-cg-r8030"
##   offer     = "check-point-cg-r8110"
##   #offer     = "check-point-cg-r8020-blink-v2"
##   plan      = "sg-byol"
## }

# To accept terms for creation of Check Point machine, run following in Azure Bash:
# az vm image terms accept --publisher checkpoint --offer 'check-point-cg-r8110' --plan 'sg-byol'

# ######################################################
# # Here we access existing RG, Vnet and subnets, which we created in vnet_central_hub
# Get resource group
data "azurerm_resource_group" "rg" {
  name = var.my_resource_gr
}
output "rg" {
  value = data.azurerm_resource_group.rg.name
}

# Get vnet
data "azurerm_virtual_network" "vnet" {
  name                = var.my_vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}
output "vnet" {
  value = data.azurerm_virtual_network.vnet.name
}

# Get existing subnets
data "azurerm_subnet" "gwexternalsubnet" {
  name                 = "External"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
}

data "azurerm_subnet" "gwinternalsubnet" {
  name                 = "Internal"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
}
# # #########################################################

resource "azurerm_public_ip" "gwpublicip" {
    name                         = "CHKPPublicIPGw"
    location                     = data.azurerm_resource_group.rg.location
    resource_group_name          = data.azurerm_resource_group.rg.name
     allocation_method           = "Static"
}

resource "azurerm_network_interface" "gwexternal" {
  name                = "gwexternal"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  enable_ip_forwarding = "true"
	ip_configuration {
        name                          = "gwexternalConfiguration"
        subnet_id                     = data.azurerm_subnet.gwexternalsubnet.id
        private_ip_address_allocation = "Static"
		private_ip_address = "10.95.0.10"
        primary = true
		public_ip_address_id = azurerm_public_ip.gwpublicip.id
    }
}

resource "azurerm_network_interface" "gwinternal" {
  name                = "gwinternal"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  enable_ip_forwarding = "true"
	ip_configuration {
        name                          = "gwinternalConfiguration"
        subnet_id                     = data.azurerm_subnet.gwinternalsubnet.id
        private_ip_address_allocation = "Static"
		private_ip_address = "10.95.1.10"
        primary = false
    }
}

# # Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = data.azurerm_resource_group.rg.name
    }
    byte_length = 8
}

# # Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = data.azurerm_resource_group.rg.name
    location                    = data.azurerm_resource_group.rg.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

# # # Create virtual machine
resource "azurerm_virtual_machine" "chkpgw" {
    name                  = "r81dot10gw"
    location              = data.azurerm_resource_group.rg.location
    resource_group_name   = data.azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.gwexternal.id, azurerm_network_interface.gwinternal.id ]
    primary_network_interface_id = azurerm_network_interface.gwexternal.id
    delete_os_disk_on_termination = true
    vm_size               = "Standard_D4s_v3"

    storage_os_disk {
        name              = "R80dot20OsDisk3"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "StandardSSD_LRS"
    }

    storage_image_reference {
        publisher = "checkpoint"
        #offer     = "check-point-cg-r8020-blink-v2"
        #offer     = "check-point-cg-r8030"
        offer     = "check-point-cg-r8110"
        sku       = "sg-byol"
        version   = "latest"
    }

    plan {
        name = "sg-byol"
        publisher = "checkpoint"
        #product = "check-point-cg-r8020-blink-v2"
        #product = "check-point-cg-r8030"
        product = "check-point-cg-r8110"#         
    }
    
#     # storage_image_reference {
#     #   publisher = "checkpoint"
#     #   offer = "check-point-vsec-r80"
#     #   sku = "sg-byol"
#     #   version = "latest"
#     # }

#     # plan {
#     #   name = "sg-byol"
#     #   publisher = "checkpoint"
#     #   product = "check-point-vsec-r80"
#     # }

    os_profile {
        computer_name  = "r81dot21gw"
        admin_username = "azure"
        admin_password = "Cpwins1!"
        custom_data = var.my_custom_data
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

}
