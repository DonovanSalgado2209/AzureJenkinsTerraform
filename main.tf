resource "azurerm_resource_group" "myterraformgroup" {
  name     = "myResourceGroup"
  location = "East US"
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

resource "azuread_user" "example" {
  display_name        = "kavyaJDoe"
  password            = "notSecure123"
  user_principal_name = "xxx.onmicrosoft.com"
}


resource "azuread_group" "example" {
  display_name     = "kavyaMyGroup"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    azuread_user.example.object_id,
    # more users 
   ]
}


resource "azuread_group" "this"{
  count = length(var.ad_groups)
  display_name =  var.ad_groups[count.index].display_name
  description = var.ad_groups[count.index].description
  security_enabled = true
  # prevent_duplicate_names = true  
  owners  = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_assignment" "sp-tenant-global-admin-user-access-role-assignment" {
  count = length(var.ad_groups)
  scope                ="/subscriptions/bb133ad6-61e6-48e1-a542-19e60290f40e/resourcegroups/myrg"     
  role_definition_name = var.ad_groups[count.index].role
  principal_id         = azuread_group.this[count.index].object_id

  depends_on = [
    azuread_group.this
  ]  
}
