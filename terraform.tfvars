# Terraform Variables Configuration
# Copy this file to terraform.tfvars and update the values as needed

# Resource Configuration
resource_group_name = "MTECH"
location           = "Central India"
vnet_name          = "MTech_Network"
subnet_name        = "subnet-project"

# VM Configuration
vm_count    = 3
vm_size     = ["Standard_B1s", "Standard_B2s", "Standard_B1s"]
vm_prefix   = "mansivm"

# Administrator Credentials (CHANGE THESE!)
admin_username = "Mansi"
admin_password = "YourSecurePassword123!"

# Domain Configuration
domain_name           = "mtech.local"
domain_admin_username = "DomainAdmin"
domain_admin_password = "YourDomainAdminPassword123!"

# Note: For production use, consider using Azure Key Vault for sensitive values
# or environment variables instead of storing passwords in this file
