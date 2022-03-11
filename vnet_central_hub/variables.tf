variable "my_resource_gr" {
  default="ODL-azure-558378-01"
}


variable "my_vnet_name" {
  default="VNet_Central_Hub"  
}

variable "vnet_cidr" {
  default="10.95.0.0/20"
}

variable "cp_mgmt_admin_username" {
  default="azureuser"
}
 
variable "cp_mgmt_admin_password" {
  default="Cpwins1!"
}

# For subnet
variable "subnet_external_name" {
  default="External"
}

variable "subnet_internal_name" {
  default="Internal"
}

variable "subnet_dmz1_name" {
  default="subnet_dmz1"
}

  