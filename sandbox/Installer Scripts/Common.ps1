# Common functions for installation scripts
# Author: fuji97
# Last Updated: August 14, 2025

function Test-WingetInstalled {
    try {
        $wingetVersion = winget --version
        if ($wingetVersion) {
            Write-Host "Winget is installed. Version: $wingetVersion" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Warning "Winget is not installed or not accessible."
        return $false
    }
}

function Install-WingetIfNeeded {
    if (-not (Test-WingetInstalled)) {
        Write-Host "Attempting to install Winget automatically..." -ForegroundColor Yellow
        
        $scriptPath = Join-Path $PSScriptRoot "Install-Winget.ps1"
        if (Test-Path $scriptPath) {
            Write-Host "Running Install-Winget.ps1..." -ForegroundColor Cyan
            try {
                & $scriptPath
                
                # Test again after installation
                if (Test-WingetInstalled) {
                    Write-Host "Winget installation completed successfully!" -ForegroundColor Green
                    return $true
                } else {
                    Write-Error "Winget installation failed or is not accessible after installation."
                    return $false
                }
            } catch {
                Write-Error "Failed to run Install-Winget.ps1: $($_.Exception.Message)"
                return $false
            }
        } else {
            Write-Error "Install-Winget.ps1 not found at $scriptPath. Please install Winget manually."
            return $false
        }
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
        
        [string]$AdditionalMessage = ""
    )
    
    Write-Host "Starting $DisplayName installation..." -ForegroundColor Yellow
    
    try {
        # Accept source agreements to avoid prompts
        if ($AcceptLicense.IsPresent) {
            Write-Host "Accepting source agreements..." -ForegroundColor Cyan
            winget list --accept-source-agreements | Out-Null
        }
        
        Write-Host "Installing $DisplayName..." -ForegroundColor Cyan
        
        # Install the package
        $installArgs = @("install", "--id", $PackageId, "--source", "winget")
        
        if ($AcceptLicense.IsPresent) {
            $installArgs += "--accept-package-agreements"
        }
        
        $result = & winget @installArgs
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$DisplayName installed successfully!" -ForegroundColor Green
            if ($AdditionalMessage) {
                Write-Host $AdditionalMessage -ForegroundColor Yellow
            }
        } else {
            Write-Error "Failed to install $DisplayName. Exit code: $LASTEXITCODE"
            Write-Host "Output: $result" -ForegroundColor Red
        }
    } catch {
        Write-Error "An error occurred during installation: $($_.Exception.Message)"
    }
}
