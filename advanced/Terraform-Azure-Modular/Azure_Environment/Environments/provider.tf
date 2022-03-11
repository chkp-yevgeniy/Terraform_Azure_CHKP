provider "azurerm" {
  use_msi = true
  subscription_id = "770f5fb1-de23-4172-8ee4-33c1ba02314f"
  tenant_id       = "269a9cb0-c0dd-4672-96c1-878b2d745719"   
  client_id   = "25017812-2693-4586-8977-76c3c6ba8c1b"
  client_secret   = "buto84GVY*Po"
  skip_provider_registration = true    
  features{}
}
