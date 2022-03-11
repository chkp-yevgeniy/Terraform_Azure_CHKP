
##############################
### Environment 1
module "VNet_1" {
  source = "../../modules/azure_vnet"
  # # RG  
  rg_name = "ODL-azure-558378-01"
  vnet_name = "My_VNet_1"
  vnet_cidr = "10.122.0.0/16"    
}

# module "Subnet_1_1" {
#   source = "../../modules/azure_subnet"
#   # # RG  
#   rg_name="ODL-azure-558378-01"
#   vnet_name = "My_VNet_1"
#   subnet_name="My_Subnet_VNET_1_1"   
#   address_prefixes=["10.122.1.0/24"]
# }
##############################


# ##############################
# ### Environment 2
module "VNet_2" {
  source = "../../modules/azure_vnet"
  # # RG  
  rg_name = "ODL-azure-558378-02"
  vnet_name = "My_VNet_C"
  vnet_cidr = "10.13.0.0/16"    
}

# ##############################


