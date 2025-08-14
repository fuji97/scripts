# This script will install PowerShell Core using Winget
# Requires Winget to be installed first (use Install-Winget.ps1 if needed)

# Author: fuji97
# Last Updated: August 14, 2025

param(
    [switch]$AcceptLicense = $false # If switch is included, it will automatically accept the license agreement
)

# Import common functions
. (Join-Path $PSScriptRoot "Common.ps1")

function Install-PowerShellCore {
    Install-WithWinget -PackageId "Microsoft.PowerShell" -DisplayName "PowerShell Core" -AcceptLicense:$AcceptLicense -AdditionalMessage "You may need to restart your terminal or open a new PowerShell session to use PowerShell Core."
}

# Main execution
Write-Host "PowerShell Core Installer Script" -ForegroundColor Magenta
Write-Host ""

# Check if Winget is installed
if (-not (Install-WingetIfNeeded)) {
    Write-Error "Cannot proceed without Winget. Installation failed."
    exit 1
}

# Install PowerShell Core
Install-PowerShellCore

Write-Host "Installation process completed." -ForegroundColor Magenta
