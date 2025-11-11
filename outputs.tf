// ---------------------------
// Outputs Configuration
// ---------------------------

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.rg.location
}

output "virtual_network_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "virtual_network_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = azurerm_subnet.subnet.id
}

output "vm_names" {
  description = "Names of the created virtual machines"
  value       = azurerm_windows_virtual_machine.vm[*].name
}

output "vm_public_ips" {
  description = "Public IP addresses of the virtual machines"
  value       = azurerm_public_ip.pip[*].ip_address
}

output "vm_private_ips" {
  description = "Private IP addresses of the virtual machines"
  value       = azurerm_windows_virtual_machine.vm[*].private_ip_address
}

output "domain_controller_ip" {
  description = "Private IP address of the domain controller (VM 0)"
  value       = azurerm_windows_virtual_machine.vm[0].private_ip_address
}

output "sql_server_ip" {
  description = "Private IP address of the SQL server (VM 1)"
  value       = azurerm_windows_virtual_machine.vm[1].private_ip_address
}

output "print_server_ip" {
  description = "Private IP address of the print server (VM 2)"
  value       = azurerm_windows_virtual_machine.vm[2].private_ip_address
}
