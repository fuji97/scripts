# This script will install all essential components for a complete Windows environment
# Installs: VC Redist, Microsoft Store, Winget, PowerShell Core, and Windows Terminal
# Runs the individual installer scripts in the correct dependency order

# Author: fuji97
# Last Updated: August 14, 2025

param(
    [switch]$AcceptLicense = $false, # If switch is included, it will automatically accept all license agreements
    [switch]$SkipVCRedist = $false,  # Skip VC Redist installation
    [switch]$SkipWinget = $false,    # Skip Winget installation
    [switch]$SkipMSStore = $false,   # Skip Microsoft Store installation
    [switch]$SkipPowerShell = $false, # Skip PowerShell Core installation
    [switch]$SkipTerminal = $false,   # Skip Windows Terminal installation
    [switch]$SkipVSCode = $false     # Skip Visual Studio Code installation
)

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host $Title -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
}

function Invoke-InstallerScript {
    param(
        [string]$ScriptName,
        [string]$Description,
        [switch]$Skip,
        [array]$AdditionalArgs = @()
    )
    
    if ($Skip.IsPresent) {
        Write-Host "Skipping $Description..." -ForegroundColor Yellow
        return $true
    }
    
    Write-SectionHeader $Description
    
    $scriptPath = Join-Path $PSScriptRoot $ScriptName
    if (-not (Test-Path $scriptPath)) {
        Write-Error "Script not found: $scriptPath"
        return $false
    }
    
    try {
        $scriptParameters = @()
        if ($AcceptLicense.IsPresent) {
            $scriptParameters += "-AcceptLicense"
        }
        $scriptParameters += $AdditionalArgs
        
        Write-Host "Running: $ScriptName" -ForegroundColor Cyan
        if ($scriptParameters.Count -gt 0) {
            Write-Host "Arguments: $($scriptParameters -join ' ')" -ForegroundColor Gray
        }
        
        & $scriptPath @scriptParameters
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "$Description completed successfully!" -ForegroundColor Green
            return $true
        } else {
            Write-Error "$Description failed with exit code: $LASTEXITCODE"
            return $false
        }
    } catch {
        Write-Error "Failed to run $ScriptName`: $($_.Exception.Message)"
        return $false
    }
}

function Show-InstallationSummary {
    param([hashtable]$Results)
    
    Write-SectionHeader "Installation Summary"
    
    foreach ($component in $Results.Keys) {
        $status = if ($Results[$component]) { "SUCCESS" } else { "FAILED" }
        $color = if ($Results[$component]) { "Green" } else { "Red" }
        Write-Host "$component`: $status" -ForegroundColor $color
    }
}

# Main execution
Write-Host "Complete Windows Environment Installer" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta
Write-Host "This script will install essential Windows components in the following order:" -ForegroundColor White
Write-Host "1. Visual C++ Redistributables" -ForegroundColor Gray
Write-Host "2. Windows Package Manager (Winget)" -ForegroundColor Gray
Write-Host "3. Microsoft Store" -ForegroundColor Gray
Write-Host "4. PowerShell Core" -ForegroundColor Gray
Write-Host "5. Windows Terminal" -ForegroundColor Gray
Write-Host "6. Visual Studio Code" -ForegroundColor Gray
Write-Host ""

if (-not $AcceptLicense.IsPresent) {
    Write-Host "Tip: Use -AcceptLicense to automatically accept all license agreements" -ForegroundColor Yellow
}

# Track installation results
$installationResults = @{}

# Install components in dependency order
$installationResults["VC Redistributables"] = Invoke-InstallerScript -ScriptName "Install VC Redist.ps1" -Description "Installing Visual C++ Redistributables" -Skip:$SkipVCRedist

$installationResults["Winget"] = Invoke-InstallerScript -ScriptName "Install-Winget.ps1" -Description "Installing Windows Package Manager (Winget)" -Skip:$SkipWinget

$installationResults["Microsoft Store"] = Invoke-InstallerScript -ScriptName "Install-Microsoft-Store.ps1" -Description "Installing Microsoft Store" -Skip:$SkipMSStore

# PowerShell Core and Windows Terminal depend on Winget, but they have auto-install capability
$installationResults["PowerShell Core"] = Invoke-InstallerScript -ScriptName "Install-PowerShellCore.ps1" -Description "Installing PowerShell Core" -Skip:$SkipPowerShell

$installationResults["Windows Terminal"] = Invoke-InstallerScript -ScriptName "Install-WindowsTerminal.ps1" -Description "Installing Windows Terminal" -Skip:$SkipTerminal

$installationResults["Visual Studio Code"] = Invoke-InstallerScript -ScriptName "Install-VSCode.ps1" -Description "Installing Visual Studio Code" -Skip:$SkipVSCode

# Show final summary
Show-InstallationSummary -Results $installationResults

# Check overall success
$failedComponents = $installationResults.Keys | Where-Object { -not $installationResults[$_] }
if ($failedComponents.Count -eq 0) {
    Write-Host ""
    Write-Host "All components installed successfully!" -ForegroundColor Green
    Write-Host "Your Windows environment is now ready to use." -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Warning "Some components failed to install. Please check the logs above for details."
    Write-Host "Failed components: $($failedComponents -join ', ')" -ForegroundColor Red
    Read-Host "Pause"
    exit 1
}