 provider "azurerm" {  
      skip_provider_registration = true
      features {}
    }
    resource "azurerm_storage_account" "mytststorageacc" {
      name                     = "mytststorageacc1"
      resource_group_name      = "venkat"
      location                 = "centralindia"
      account_tier             = "Standard"
      account_replication_type = "LRS"
    }
