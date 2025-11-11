
// ---------------------------
// Provider Configuration
// ---------------------------
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  
  # Uncomment and configure one of the authentication methods below:
  
  # Method 1: Use Azure CLI authentication (recommended for development)
  # No additional configuration needed if you're logged in via 'az login'
  
  # Method 2: Use service principal authentication (recommended for production)
  # subscription_id = var.subscription_id
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id
  
  # Method 3: Use managed identity (for Azure-hosted environments)
  # No additional configuration needed
}

// ---------------------------
// Resource Group
// ---------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

// ---------------------------
// Virtual Network
// ---------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

// ---------------------------
// Network Security Group
// ---------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-project"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

// NSG Rules for RDP access
resource "azurerm_network_security_rule" "rdp" {
  name                        = "RDP"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

// NSG Rules for Active Directory
resource "azurerm_network_security_rule" "ad_dns" {
  name                        = "AD-DNS"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "ad_ldap" {
  name                        = "AD-LDAP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "389"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "ad_ldaps" {
  name                        = "AD-LDAPS"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "636"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "ad_kerberos" {
  name                        = "AD-Kerberos"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "88"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

// NSG Rules for SQL Server
resource "azurerm_network_security_rule" "sql_server" {
  name                        = "SQL-Server"
  priority                    = 1005
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

// Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

// ---------------------------
// Public IPs for VMs
// ---------------------------
resource "azurerm_public_ip" "pip" {
  count               = var.vm_count
  name                = "pip-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"   
}

// ---------------------------
// Network Interfaces
// ---------------------------
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-${count.index}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.pip.*.id, count.index)
  }
}

// ---------------------------
// Virtual Machines (Windows Server 2019 Datacenter)
// ---------------------------
resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "${var.vm_prefix}-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = count.index == 1 ? "Standard_B2s" : "Standard_B1s"   # SQL = 2 CPU, others = 1 CPU
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    element(azurerm_network_interface.nic.*.id, count.index)
  ]

  os_disk {
    name              = "osdisk-${count.index}"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    Environment = "Production"
    Project     = "MTech-3VM"
    Role        = count.index == 0 ? "DomainController" : count.index == 1 ? "SQLServer" : "PrintServer"
  }
}

// ---------------------------
// VM Extensions Removed
// ---------------------------
// VM extensions have been removed for manual role installation.
// Use the provided PowerShell scripts to manually configure each VM after deployment.