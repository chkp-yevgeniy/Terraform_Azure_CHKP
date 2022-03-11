module "VNet_A" {
  source = "../../modules/azure_vnet"  
  rg_name = "ODL-azure-558378-01"
  vnet_name = "My_VNet_A"
  vnet_cidr = "10.11.0.0/16"    
}


