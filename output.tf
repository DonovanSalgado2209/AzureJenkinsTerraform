output "public_ip" {
  value = azurerm_linux_virtual_machine.myterraformmvm.public_ip_address
}
output "dns_name" {
     value = azurerm_linux_virtual_machine.myterraformmvm.public_dns
}
