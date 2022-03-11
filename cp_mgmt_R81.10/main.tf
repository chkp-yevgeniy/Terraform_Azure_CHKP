# resource "azurerm_marketplace_agreement" "checkpoint" {
#   publisher = "checkpoint"
#   offer     = "check-point-cg-r8020-blink-v2"
#   plan      = "sg-byol"
# }

### NOTE!!!
# To accept terms for creation of Check Point machine, run following in Azure Bash:
# az vm image terms accept --publisher checkpoint --offer 'check-point-cg-r8110' --plan 'mgmt-byol'

# ######################################################
# # Here we access existing RG, Vnet and subnets, which we created in vnet_central_hub
data "azurerm_resource_group" "rg" {
  name = var.my_resource_gr
}

data "azurerm_virtual_network" "vnet" {
  name                = var.my_vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

output "rg" {
  value = "${data.azurerm_resource_group.rg.name}"
}

data "azurerm_subnet" "gwexternalsubnet" {
  name                 = "External"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "gwinternalsubnet" {
  name                 = "Internal"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}
######################################################

resource "azurerm_public_ip" "ip_cp_mgmt_2" {
    name                         = "ip_cp_mgmt_2"
    location                     = data.azurerm_resource_group.rg.location
    resource_group_name          = data.azurerm_resource_group.rg.name
     allocation_method           = "Static"
}

resource "azurerm_network_interface" "nic_mgmt_external_2" {
    name                = "nic_mgmt_external_2"
    location            = data.azurerm_resource_group.rg.location
    resource_group_name = data.azurerm_resource_group.rg.name
    enable_ip_forwarding = "true"
	ip_configuration {
        name                          = "gwexternalConfiguration"
        subnet_id                     = data.azurerm_subnet.gwexternalsubnet.id
        private_ip_address_allocation = "Static"
		private_ip_address = "10.95.0.101"
        primary = true
		public_ip_address_id = azurerm_public_ip.ip_cp_mgmt_2.id
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${data.azurerm_resource_group.rg.name}"
    }
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${data.azurerm_resource_group.rg.name}"
    location                    = "${data.azurerm_resource_group.rg.location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}



resource "azurerm_virtual_machine" "chkpmgmt" {
    name                  = "chkp_r81dot10_mgmt_2"
    location              = data.azurerm_resource_group.rg.location
    resource_group_name   = data.azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic_mgmt_external_2.id]
    primary_network_interface_id = azurerm_network_interface.nic_mgmt_external_2.id
    vm_size               = "Standard_D4s_v3"
    
    #depends_on = [azurerm_marketplace_agreement.checkpoint]

    storage_os_disk {
        name              = "R81dot10OsDisk2"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "checkpoint"
        offer     = "check-point-cg-r8110"
        sku       = "mgmt-byol"
        version   = "latest"
    }

    plan {
        name = "mgmt-byol"
        publisher = "checkpoint"
        #product = "check-point-cg-r8040"
        product = "check-point-cg-r8110"
        }
    os_profile {
        computer_name  = "r81dot10mgmt"
        admin_username = "azureuser"
        admin_password = "Cpwins1!!"
        custom_data = file("customdata.sh") 
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

}
