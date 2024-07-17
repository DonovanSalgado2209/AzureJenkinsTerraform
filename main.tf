resource "azurerm_resource_group" "myterraformgroup" {
  name     = "VM"
  location = "East US"
}

resource "azurerm_virtual_network" "myterraformnetwork" {
  name                   = "AzureJenkinsTerraform-vnet"
  address_space          = ["10.1.0.0/16"]
  location               = "East US"
  resource_group_name    = azurerm_resource_group.myterraformgroup.name
}

resource "azurerm_subnet" "myterraformsubnet" {
  name                    = "default"
  resource_group_name     = azurerm_resource_group.myterraformgroup.name
  virtual_network_name    = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes        = ["10.1.0.0/24"]
}

resource "azurerm_public_ip" "myterraformpublicip" {
  name                    = "ipconfig1"
  location                = "East US"
  resource_group_name     = azurerm_resource_group.myterraformgroup.name
  allocation_method       = "Static"
}

resource "azurerm_network_security_group" "myterraformnsg" {
  name                   = "AzureJenkinsTerraform-nsg"
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
    name                   = "azurejenkinsterraform176_z1"
    location               = "East US"
    resource_group_name    = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
      name                              = "ipconfig1"
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
    name                   = "AzureJenkinsTerraform"
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
    admin_username                   = "dono"
    admin_password                   = "Donovansalazar22"
    disable_password_authentication  = false
  }
