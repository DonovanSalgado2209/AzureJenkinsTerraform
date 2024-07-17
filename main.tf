resource "azurerm_resource_group" "myterraformgroup" {
  name     = "myResourceGroup"
  location = "East US"
}

resource "azuread_service_principal" "example" {
  application_id               = azuread_application.example.application_id
  app_role_assignment_required = false

  tags = ["example", "tags", "here"]
}
resource "azurerm_key_vault" "example" {
  name                        = "testvault"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = azuread_service_principal.example.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]

    storage_permissions = [
      "get",
    ]
  }
}

resource "azurerm_virtual_network" "myterraformnetwork" {
  name                   = "myVnet"
  address_space          = ["10.0.0.0/16"]
  location               = "East US"
  resource_group_name    = azurerm_resource_group.myterraformgroup.name
}

resource "azurerm_subnet" "myterraformsubnet" {
  name                    = "mySubnet"
  resource_group_name     = azurerm_resource_group.myterraformgroup.name
  virtual_network_name    = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes        = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "myterraformpublicip" {
  name                    = "myPublicIP"
  location                = "East US"
  resource_group_name     = azurerm_resource_group.myterraformgroup.name
  allocation_method       = "Static"
}

resource "azurerm_network_security_group" "myterraformnsg" {
  name                   = "myNetworkSecurityGroup"
  location               = "East US"
  resource_group_name    = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                          = "SSH"
    priority                      = 1001
    direction                     = "Inbound"
    access                        = "Allow"
    protocol                      = "Tcp"
    source_port_range             = "*"
    destination_port_ranges       = ["22", "80", "443", "32323"]
    source_address_prefix         = "*"
    destination_address_prefix    = "*"
  }
}

  resource "azurerm_network_interface" "myterraformnic" {
    name                   = "myNIC"
    location               = "East US"
    resource_group_name    = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
      name                              = "myNicConfig"
      subnet_id                         = azurerm_subnet.myterraformsubnet.id
      private_ip_address_allocation     = "Dynamic"
      public_ip_address_id              = azurerm_public_ip.myterraformpublicip.id
    }
  } 

  resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id       = azurerm_network_interface.myterraformnic.id
    network_security_group_id  = azurerm_network_security_group.myterraformnsg.id
  }

  resource "azurerm_linux_virtual_machine" "myterraformmvm" {
    name                   = "myVM"
    location               = "East US"
    resource_group_name    = azurerm_resource_group.myterraformgroup.name
    network_interface_ids  = [azurerm_network_interface.myterraformnic.id]
    size                   = "Standard_DS1_v2"

    os_disk {
      name                 = "myOsDisk"
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }

    computer_name                    = "myvm"
    admin_username                   = "donovis"
    admin_password                   = "Donovansalazar22"
    disable_password_authentication  = false
  }
