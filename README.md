# Azure 3-VM Project

This Terraform project deploys a 3-VM Windows Server infrastructure on Azure with Active Directory, SQL Server, and Print Server roles.

## Architecture

- **VM 0**: Domain Controller with Active Directory Domain Services and DNS
- **VM 1**: SQL Server 2019 Express with SQL Server Management Studio
- **VM 2**: Print Server with Print and Document Services

## Prerequisites

1. **Azure CLI** installed and configured
2. **Terraform** (version 1.0 or later)
3. **Azure Subscription** with appropriate permissions
4. **PowerShell** (for running scripts locally if needed)

## Authentication Setup

Before running Terraform, you need to authenticate with Azure:

### Option 1: Azure CLI Authentication (Recommended for Development)

1. **Install Azure CLI** if not already installed:
   ```bash
   # Windows (using winget)
   winget install Microsoft.AzureCLI
   
   # Or download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
   ```

2. **Login to Azure**:
   ```bash
   az login
   ```

3. **Verify authentication**:
   ```bash
   az account show
   ```

### Option 2: Service Principal Authentication (Recommended for Production)

1. **Create a service principal**:
   ```bash
   az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
   ```

2. **Update terraform.tfvars** with the service principal details:
   ```hcl
   subscription_id = "your-subscription-id"
   client_id       = "your-client-id"
   client_secret   = "your-client-secret"
   tenant_id       = "your-tenant-id"
   ```

3. **Uncomment the authentication variables** in `variables.tf` and `main.tf`

### Quick Setup Script

Run the provided setup script to check your authentication:

```powershell
.\setup-azure-auth.ps1
```

## Quick Start

1. **Clone or download** this repository
2. **Set up Azure authentication** (see Authentication Setup section above)
3. **Update variables** in `terraform.tfvars`:
   ```hcl
   # Change these values!
   admin_password = "YourSecurePassword123!"
   domain_admin_password = "YourDomainAdminPassword123!"
   ```
4. **Initialize Terraform**:
   ```bash
   terraform init
   ```
5. **Plan deployment**:
   ```bash
   terraform plan
   ```
6. **Deploy infrastructure**:
   ```bash
   terraform apply
   ```

## Configuration

### Variables

Key variables you can customize in `terraform.tfvars`:

- `resource_group_name`: Azure resource group name
- `location`: Azure region (e.g., "East US")
- `vm_count`: Number of VMs (default: 3)
- `vm_size`: VM size (default: "Standard_B2s")
- `vm_prefix`: Prefix for VM names
- `domain_name`: Active Directory domain name
- `admin_username`/`admin_password`: Local administrator credentials
- `domain_admin_username`/`domain_admin_password`: Domain administrator credentials

### Network Configuration

- **VNet**: 10.0.0.0/16
- **Subnet**: 10.0.1.0/24
- **NSG Rules**: Configured for RDP, AD, DNS, and SQL Server ports

## VM Roles and Services

### Domain Controller (VM 0)
- Active Directory Domain Services
- DNS Server
- Domain: `mtech.local` (configurable)
- Organizational Units: Computers, Users, Servers

### SQL Server (VM 1)
- SQL Server 2019 Express
- SQL Server Management Studio
- Instance: SQLEXPRESS
- Port: 1433

### Print Server (VM 2)
- Print and Document Services
- Print Server role
- Shared printer management

## Post-Deployment

After deployment completes, you need to manually install and configure the roles on each VM:

### Step 1: RDP to Each VM
Use the public IP addresses from the Terraform outputs to RDP to each VM:
- **VM 0**: Domain Controller
- **VM 1**: SQL Server  
- **VM 2**: Print Server

### Step 2: Manual Role Installation

#### Domain Controller (VM 0)
1. **Copy the script**: Copy `scripts/install_ad_dns.ps1` to the VM
2. **Run PowerShell as Administrator**
3. **Execute the script**:
   ```powershell
   .\install_ad_dns.ps1 -DomainName "mtech.local" -DomainAdminPassword "YourDomainAdminPassword123!"
   ```
4. **Restart** the VM when prompted

#### SQL Server (VM 1)
1. **Copy the script**: Copy `scripts/install_sql.ps1` to the VM
2. **Run PowerShell as Administrator**
3. **Execute the script**:
   ```powershell
   .\install_sql.ps1
   ```

#### Print Server (VM 2)
1. **Copy the script**: Copy `scripts/install_print.ps1` to the VM
2. **Run PowerShell as Administrator**
3. **Execute the script**:
   ```powershell
   .\install_print.ps1
   ```

### Step 3: Domain Join (SQL and Print Servers)
After the Domain Controller is configured:

1. **Copy the script**: Copy `scripts/join_domain.ps1` to SQL and Print servers
2. **Run PowerShell as Administrator**
3. **Execute the script**:
   ```powershell
   .\join_domain.ps1 -DomainName "mtech.local" -DomainAdminUsername "DomainAdmin" -DomainAdminPassword "YourDomainAdminPassword123!"
   ```

### Step 4: Final Configuration
1. **Copy the script**: Copy `scripts/post_provision.ps1` to all VMs
2. **Run PowerShell as Administrator**
3. **Execute the script**:
   ```powershell
   .\post_provision.ps1
   ```

### Step 5: Verify Services
- **Domain Controller**: Check AD DS and DNS in Server Manager
- **SQL Server**: Connect using SQL Server Management Studio
- **Print Server**: Check Print Management console

## Security Considerations

⚠️ **Important Security Notes**:

1. **Change default passwords** in `terraform.tfvars`
2. **Use Azure Key Vault** for production deployments
3. **Restrict NSG rules** to specific IP ranges
4. **Enable Azure Security Center** recommendations
5. **Regular updates** and patching

## Troubleshooting

### Common Issues

1. **PowerShell script execution blocked**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   ```

2. **Domain join issues**:
   - Ensure Domain Controller is running and configured first
   - Check DNS resolution (ping domain controller by name)
   - Verify domain credentials
   - Check Windows Firewall rules

3. **SQL Server connection**:
   - Check Windows Firewall rules
   - Verify SQL Server service is running
   - Test connectivity on port 1433
   - Ensure SQL Server is configured to accept connections

4. **Active Directory installation**:
   - Ensure server has static IP address
   - Check DNS forwarders are configured
   - Verify server can resolve external DNS

### Logs and Monitoring

- **Windows Event Logs**: Application, System, Security
- **System Information**: `C:\SystemInfo.txt` on each VM (created by post_provision.ps1)
- **PowerShell Script Logs**: Check console output when running scripts
- **Azure Portal**: Monitor VM health and resource usage

## Cost Optimization

- **VM Sizes**: Consider smaller sizes for development/testing
- **Storage**: Use Standard_LRS for non-critical workloads
- **Auto-shutdown**: Implement auto-shutdown policies for dev environments

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

⚠️ **Warning**: This will delete all resources and data!

## Support

For issues or questions:
1. Check Azure Portal for resource status
2. Review Terraform logs
3. Check VM extension logs in Azure Portal
4. Verify network connectivity and firewall rules

## License

This project is provided as-is for educational and development purposes.
