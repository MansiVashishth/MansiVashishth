

Write-Host "Azure Authentication Setup for Terraform" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

Write-Host "`nChecking Azure CLI installation..." -ForegroundColor Yellow
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✓ Azure CLI is installed (Version: $($azVersion.'azure-cli'))" -ForegroundColor Green
}
catch {
    Write-Host "✗ Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Azure CLI from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nChecking Azure login status..." -ForegroundColor Yellow
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✓ You are logged in to Azure" -ForegroundColor Green
    Write-Host "  Subscription: $($account.name)" -ForegroundColor Cyan
    Write-Host "  Subscription ID: $($account.id)" -ForegroundColor Cyan
    Write-Host "  Tenant ID: $($account.tenantId)" -ForegroundColor Cyan
}
catch {
    Write-Host "✗ You are not logged in to Azure" -ForegroundColor Red
    Write-Host "`nPlease log in to Azure using one of these methods:" -ForegroundColor Yellow
    
    Write-Host "`nMethod 1: Interactive login (recommended for development)" -ForegroundColor Cyan
    Write-Host "Run: az login" -ForegroundColor White
    
    Write-Host "`nMethod 2: Login with service principal (for automation)" -ForegroundColor Cyan
    Write-Host "Run: az login --service-principal --username <client-id> --password <client-secret> --tenant <tenant-id>" -ForegroundColor White
    
    Write-Host "`nAfter logging in, run this script again to verify authentication." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nChecking subscription permissions..." -ForegroundColor Yellow
try {
    $subscriptionId = $account.id
    $permissions = az role assignment list --assignee $account.user.name --scope "/subscriptions/$subscriptionId" --output json | ConvertFrom-Json
    
    $hasContributorRole = $permissions | Where-Object { $_.roleDefinitionName -eq "Contributor" -or $_.roleDefinitionName -eq "Owner" }
    
    if ($hasContributorRole) {
        Write-Host "✓ You have Contributor/Owner permissions" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ You may not have sufficient permissions to create resources" -ForegroundColor Yellow
        Write-Host "  Required roles: Contributor or Owner" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "⚠ Could not verify permissions" -ForegroundColor Yellow
}

Write-Host "`nNext Steps:" -ForegroundColor Green
Write-Host "===========" -ForegroundColor Green
Write-Host "1. Update terraform.tfvars with your values:" -ForegroundColor Yellow
Write-Host "   - Change admin_password" -ForegroundColor White
Write-Host "   - Change domain_admin_password" -ForegroundColor White
Write-Host "   - Update resource names if needed" -ForegroundColor White

Write-Host "`n2. Initialize Terraform:" -ForegroundColor Yellow
Write-Host "   terraform init" -ForegroundColor White

Write-Host "`n3. Plan the deployment:" -ForegroundColor Yellow
Write-Host "   terraform plan" -ForegroundColor White

Write-Host "`n4. Deploy the infrastructure:" -ForegroundColor Yellow
Write-Host "   terraform apply" -ForegroundColor White

Write-Host "`nAuthentication setup completed successfully!" -ForegroundColor Green
