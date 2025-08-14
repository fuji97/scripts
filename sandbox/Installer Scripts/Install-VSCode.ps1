# This script will install Visual Studio Code using Winget
# Requires Winget to be installed first (use Install-Winget.ps1 if needed)

# Author: fuji97
# Last Updated: August 14, 2025

param(
    [switch]$AcceptLicense = $false # If switch is included, it will automatically accept the license agreement
)

# Import common functions
. (Join-Path $PSScriptRoot "Common.ps1")

function Install-VSCode {
    Install-WithWinget -PackageId "Microsoft.VisualStudioCode" -DisplayName "Visual Studio Code" -AcceptLicense:$AcceptLicense
}

# Main execution
Write-Host "Visual Studio Code Installer Script" -ForegroundColor Magenta
Write-Host ""

# Check if Winget is installed
if (-not (Install-WingetIfNeeded)) {
    Write-Error "Cannot proceed without Winget. Installation failed."
    exit 1
}

# Install Visual Studio Code
Install-VSCode

Write-Host "Installation process completed." -ForegroundColor Magenta
