provider "azurerm" {
  use_msi = true
  subscription_id = "1753B339-FC28-43FB-B5E8-CF3B8F9E64F9"
  tenant_id       = "269a9cb0-c0dd-4672-96c1-878b2d745719"   
  client_id   = "ec2f8b0d-7010-4b78-af59-0b8b78e54653"
  client_secret   = "fbhm20XXV*bt"
  skip_provider_registration = true    
  features{}
}
