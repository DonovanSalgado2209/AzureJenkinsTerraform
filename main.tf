resource "azurerm_resource_group" "myterraformgroup" {
  name     = "myResourceGroup"
  location = "eastus2"
}

resource "azurerm_virtual_network" "myterraformnetwork" {
  name                   = "myVnet"
  address_space          = ["10.0.0.0/16"]
  location               = "eastus2"
  resource_group_name    = azurerm_resource_group.myterraformgroup.name
}

resource "azurerm_subnet" "myterraformsubnet" {
  name                    = "mySubnet"
  resource_group_name     = azurerm_resource_group.myterraformgroup.name
  virtual_network_name    = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes        = ["10.0.1.0/24"]
delegation {
    name = "delegation"

    service_delegation {
      name = "NGINX.NGINXPLUS/nginxDeployments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_nginx_deployment" "example" {
  name                     = "example-nginx"
  resource_group_name      = azurerm_resource_group.example.name
  sku                      = "publicpreview_Monthly_gmz7xq9ge3py"
  location                 = azurerm_resource_group.example.location
  managed_resource_group   = "example"
  diagnose_support_enabled = true

  frontend_public {
    ip_address = [azurerm_public_ip.example.id]
  }
  network_interface {
    subnet_id = azurerm_subnet.example.id
  }
}

resource "azurerm_nginx_configuration" "example" {
  nginx_deployment_id = azurerm_nginx_deployment.example.id
  root_file           = "/etc/nginx/nginx.conf"

  config_file {
    content = base64encode(<<-EOT
http {
    server {
        listen 80;
        location / {
            default_type text/html;
            return 200 '<!doctype html><html lang="en"><head></head><body>
                <div>this one will be updated</div>
                <div>at 10:38 am</div>
            </body></html>';
        }
        include site/*.conf;
    }
}
EOT
    )
    virtual_path = "/etc/nginx/nginx.conf"
  }

  config_file {
    content = base64encode(<<-EOT
location /bbb {
 default_type text/html;
 return 200 '<!doctype html><html lang="en"><head></head><body>
  <div>this one will be updated</div>
  <div>at 10:38 am</div>
 </body></html>';
}
EOT
    )
    virtual_path = "/etc/nginx/site/b.conf"
  }
}



resource "azurerm_public_ip" "myterraformpublicip" {
  name                    = "myPublicIP"
  location                = "eastus2"
  resource_group_name     = azurerm_resource_group.myterraformgroup.name
  allocation_method       = "Static"
}

resource "azurerm_network_security_group" "myterraformnsg" {
  name                   = "myNetworkSecurityGroup"
  location               = "eastus2"
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
    location               = "eastus2"
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
    name                   = "DonoVM"
    location               = "eastus2"
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

    computer_name                    = "DonoVM"
    admin_username                   = "d"
    admin_password                   = "Donovansalazar22$"
    disable_password_authentication  = false
  }

