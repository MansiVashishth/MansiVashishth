// ---------------------------
// Variables Configuration
// ---------------------------

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "MTECH"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Central India"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "MTech_Network"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "subnet-project"
}

variable "vm_count" {
  description = "Number of virtual machines to create"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Administrator username for VMs"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Administrator password for VMs"
  type        = string
  sensitive   = true
}

variable "vm_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "mansivm"
}

variable "domain_name" {
  description = "Domain name for Active Directory"
  type        = string
  default     = "mtech.local"
}

variable "domain_admin_username" {
  description = "Domain administrator username"
  type        = string
  default     = "DomainAdmin"
}

variable "domain_admin_password" {
  description = "Domain administrator password"
  type        = string
  sensitive   = true
}

// ---------------------------
// Azure Authentication Variables (Optional)
// ---------------------------
// Uncomment these variables if using service principal authentication

# variable "subscription_id" {
#   description = "Azure subscription ID"
#   type        = string
#   sensitive   = true
# }

# variable "client_id" {
#   description = "Azure service principal client ID"
#   type        = string
#   sensitive   = true
# }

# variable "client_secret" {
#   description = "Azure service principal client secret"
#   type        = string
#   sensitive   = true
# }

# variable "tenant_id" {
#   description = "Azure tenant ID"
#   type        = string
#   sensitive   = true
# }
