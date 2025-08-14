# PowerShell Development Environment Setup Script
# This script installs Windows Terminal, PowerShell Core, Oh My Posh, and sets up PowerShell profile
# Author: fuji97
# Last Updated: August 14, 2025

param(
    [switch]$AcceptLicense = $false, # If switch is included, it will automatically accept license agreements
    [switch]$Force = $false # Force reinstallation even if already installed
)

# Color scheme for output
$Colors = @{
    Header = "Magenta"
    Success = "Green"
    Warning = "Yellow"
    Info = "Cyan"
    Error = "Red"
}

function Write-Header {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Colors.Header
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Colors.Success
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Colors.Info
}

function Write-Warning {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Colors.Warning
}

function Test-WingetInstalled {
    try {
        $wingetVersion = winget --version 2>$null
        if ($wingetVersion) {
            Write-Info "Winget is installed. Version: $wingetVersion"
            return $true
        }
    } catch {
        Write-Warning "Winget is not installed or not accessible."
        return $false
    }
}

function Install-WingetIfNeeded {
    if (-not (Test-WingetInstalled)) {
        Write-Warning "Winget is required but not installed."
        Write-Info "Please install Winget from the Microsoft Store or visit:"
        Write-Info "https://github.com/microsoft/winget-cli/releases"
        return $false
    }
    return $true
}

function Install-WithWinget {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageId,
        
        [Parameter(Mandatory=$true)]
        [string]$DisplayName,
        
        [switch]$AcceptLicense,

        [switch]$Force = $false,
        
        [string]$AdditionalMessage = ""
    )

    Write-Info "Starting $DisplayName installation..."

    try {
        # Accept source agreements to avoid prompts
        if ($AcceptLicense.IsPresent) {
            Write-Info "Accepting source agreements..."
            winget list --accept-source-agreements | Out-Null
        }

        # Check if package is already installed
        $installed = winget list --id $PackageId --exact 2>$null | Select-String -Pattern $PackageId
        if ($installed -and -not $Force) {
            Write-Success "$DisplayName is already installed. Use -Force to reinstall."
            return $true
        }

        Write-Info "Installing $DisplayName..."

        # Install the package
        $installArgs = @("install", "--id", $PackageId, "--source", "winget")
        
        if ($AcceptLicense.IsPresent) {
            $installArgs += "--accept-package-agreements"
            $installArgs += "--accept-source-agreements"
        }

        if ($Force) {
            $installArgs += "--force"
        }
        
        $result = & winget @installArgs

        Write-Debug "Output: $result"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$DisplayName installed successfully!"
            if ($AdditionalMessage) {
                Write-Warning $AdditionalMessage
            }
            return $true
        } else {
            Write-Error "Failed to install $DisplayName. Exit code: $LASTEXITCODE"
            return $false
        }
    } catch {
        Write-Error "An error occurred during installation: $($_.Exception.Message)"
        return $false
    }
}

function Install-OhMyPosh {
    Write-Info "Checking if Oh My Posh is already installed..."
    
    # Check if oh-my-posh command is available
    try {
        $version = oh-my-posh version 2>$null
        if ($version -and -not $Force) {
            Write-Success "Oh My Posh is already installed. Version: $version"
            return $true
        }
    } catch {
        # Not installed, continue with installation
    }
    
    Write-Info "Installing Oh My Posh..."
    
    try {
        # Install Oh My Posh using winget
        $result = Install-WithWinget -PackageId "JanDeDobbeleer.OhMyPosh" -DisplayName "Oh My Posh" -AcceptLicense:$AcceptLicense
        
        if ($result) {
            Write-Success "Oh My Posh installed successfully!"
            Write-Warning "You may need to restart your terminal for Oh My Posh to be available in PATH."
            return $true
        } else {
            Write-Error "Failed to install Oh My Posh with winget."
            return $false
        }
    } catch {
        Write-Error "An error occurred during Oh My Posh installation: $($_.Exception.Message)"
        return $false
    }
}

function Install-PowerShellProfile {
    Write-Info "Setting up PowerShell profile..."
    
    $profileUrl = "https://raw.githubusercontent.com/fuji97/scripts/main/Microsoft.PowerShell_profile.ps1"
    $profilePath = $PROFILE.AllUsersAllHosts
    
    # Create profile directory if it doesn't exist
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        Write-Info "Creating profile directory: $profileDir"
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    # Check if profile already exists
    if (Test-Path $profilePath) {
        Write-Warning "PowerShell profile already exists at: $profilePath"
        Write-Warning "To avoid overwriting your existing configuration, this script will not replace it."
        Write-Info "If you want to use the profile from GitHub, please:"
        Write-Info "  1. View the profile at: $profileUrl"
        Write-Info "  2. Manually merge the desired settings into your existing profile"
        Write-Info "  3. Or rename/backup your current profile and run this script again"
        Write-Success "PowerShell profile check completed (existing profile preserved)."
        return $true
    }
    
    try {
        Write-Info "Downloading PowerShell profile from GitHub..."
        $webClient = New-Object System.Net.WebClient
        $profileContent = $webClient.DownloadString($profileUrl)
        
        # Write new profile
        Write-Info "Installing PowerShell profile to: $profilePath"
        $profileContent | Out-File -FilePath $profilePath -Encoding UTF8
        
        Write-Success "PowerShell profile installed successfully!"
        Write-Warning "Please restart your PowerShell session to apply the new profile."
        
        return $true
    } catch {
        Write-Error "Failed to download or install PowerShell profile: $($_.Exception.Message)"
        return $false
    }
}

function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    Write-Info "PowerShell version: $psVersion"
    
    if ($psVersion.Major -lt 5) {
        Write-Error "PowerShell 5.0 or higher is required."
        return $false
    }
    
    # Check internet connectivity
    try {
        Test-Connection -ComputerName "github.com" -Count 1 -Quiet | Out-Null
        Write-Info "Internet connectivity verified."
    } catch {
        Write-Error "Internet connection is required to download components."
        return $false
    }
    
    return $true
}

# Main execution
Clear-Host
Write-Header "======================================================"
Write-Header "    PowerShell Development Environment Setup"
Write-Header "======================================================"
Write-Host ""
Write-Info "This script will install:"
Write-Info "  - Windows Terminal"
Write-Info "  - PowerShell Core" 
Write-Info "  - Oh My Posh"
Write-Info "  - PowerShell Profile from GitHub"
Write-Host ""

if ($AcceptLicense) {
    Write-Info "License agreements will be accepted automatically."
}

if ($Force) {
    Write-Warning "Force mode enabled - will reinstall components even if already present."
}

Write-Host ""

# Check prerequisites
if (-not (Test-Prerequisites)) {
    Write-Error "Prerequisites check failed. Cannot continue."
    exit 1
}

# Check if Winget is installed
if (-not (Install-WingetIfNeeded)) {
    Write-Error "Cannot proceed without Winget. Installation failed."
    exit 1
}

Write-Host ""
Write-Header "Starting installations..."
Write-Host ""

$installationResults = @{}

# Install Windows Terminal
Write-Header "1. Installing Windows Terminal..."
$installationResults["WindowsTerminal"] = Install-WithWinget -PackageId "Microsoft.WindowsTerminal" -DisplayName "Windows Terminal" -AcceptLicense:$AcceptLicense

Write-Host ""

# Install PowerShell Core
Write-Header "2. Installing PowerShell Core..."
$installationResults["PowerShellCore"] = Install-WithWinget -PackageId "Microsoft.PowerShell" -DisplayName "PowerShell Core" -AcceptLicense:$AcceptLicense -AdditionalMessage "You may need to restart your terminal to use PowerShell Core."

Write-Host ""

# Install Oh My Posh
Write-Header "3. Installing Oh My Posh..."
$installationResults["OhMyPosh"] = Install-OhMyPosh

Write-Host ""

# Install PowerShell Profile
Write-Header "4. Installing PowerShell Profile..."
$installationResults["PowerShellProfile"] = Install-PowerShellProfile

Write-Host ""

# Summary
Write-Header "======================================================"
Write-Header "                  Installation Summary"
Write-Header "======================================================"
Write-Host ""

$allSuccessful = $true
foreach ($component in $installationResults.Keys) {
    $status = if ($installationResults[$component]) { "SUCCESS" } else { "FAILED" }
    $color = if ($installationResults[$component]) { $Colors.Success } else { $Colors.Error }
    
    Write-Host "  $component`.PadRight(20): $status" -ForegroundColor $color
    
    if (-not $installationResults[$component]) {
        $allSuccessful = $false
    }
}

Write-Host ""

if ($allSuccessful) {
    Write-Success "All components installed successfully!"
    Write-Host ""
    Write-Warning "IMPORTANT: Please restart your terminal or open a new PowerShell session to:"
    Write-Warning "  - Use the new PowerShell profile"
    Write-Warning "  - Access PowerShell Core (pwsh command)"
    Write-Warning "  - Use Oh My Posh themes"
} else {
    Write-Error "Some components failed to install. Please check the errors above."
    exit 1
}

Write-Host ""
Write-Header "Setup completed!"
