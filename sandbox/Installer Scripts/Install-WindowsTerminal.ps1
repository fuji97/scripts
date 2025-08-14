# This script will install Windows Terminal using Winget
# Requires Winget to be installed first (use Install-Winget.ps1 if needed)

# Author: fuji97
# Last Updated: August 14, 2025

param(
    [switch]$AcceptLicense = $false # If switch is included, it will automatically accept the license agreement
)

# Import common functions
. (Join-Path $PSScriptRoot "Common.ps1")

function Install-WindowsTerminal {
    Install-WithWinget -PackageId "Microsoft.WindowsTerminal" -DisplayName "Windows Terminal" -AcceptLicense:$AcceptLicense
}

# Main execution
Write-Host "Windows Terminal Installer Script" -ForegroundColor Magenta
Write-Host ""

# Check if Winget is installed
if (-not (Install-WingetIfNeeded)) {
    Write-Error "Cannot proceed without Winget. Installation failed."
    exit 1
}

# Install Windows Terminal
Install-WindowsTerminal

Write-Host "Installation process completed." -ForegroundColor Magenta
