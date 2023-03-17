Import-Module posh-git
Import-Module oh-my-posh
oh-my-posh init pwsh --config $env:POSH_THEMES_PATH\blue-owl.omp.json | Invoke-Expression

# Add Chocolatey
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# 'su' command
Function WT-Admin { 
    $curDir = Get-Location
    Start-Process -Verb RunAs cmd.exe "/c start wt.exe -d $curDir" 
}

# Quick access to GPG keys
function Get-GpgKeys { 
    param(
        [string]$ExportParam
    )

    if ($ExportParam) {
        gpg --armor --export $ExportParam
    } else {
        gpg --list-secret-keys --keyid-format=long 
    }
}

# Navigate to special location
function Set-SpecialLocation {
  [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$EnvFolder
    )
    $envPath = [Environment]::GetFolderPath($EnvFolder)
    Set-Location $envPath
}

# Shell-style aliases
Set-Alias su WT-Admin
Set-Alias gpg-keys Get-GpgKeys
Set-Alias cds Set-SpecialLocation