# variable "rg_name" {
#   default="ResourceGroup_X"
# }

variable "rg_name" {
  default=""
}

variable "vnet_name" {
  default="VNet_X"
}

variable "my_location" {
  default="West Europe"
}

variable "vnet_cidr" {
  default="10.95.0.0/20"
}
