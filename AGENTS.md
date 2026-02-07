# Agent Guidelines for PowerShell Scripts Repository

This document provides guidelines for AI coding agents working in this PowerShell scripts repository.

## Project Overview

This is a Windows PowerShell automation toolkit focused on:
- PowerShell development environment setup
- Windows Sandbox configuration and automation
- General-purpose PowerShell utility scripts
- System configuration and tweaks

**Primary Technologies:** PowerShell (Windows PowerShell 5.1+ and PowerShell Core 7+), Windows Sandbox, Winget, Oh My Posh

**Repository:** https://github.com/fuji97/scripts.git

## Repository Structure

```
scripts/
├── powershell/              # General-purpose PowerShell utilities
├── sandbox/                 # Windows Sandbox automation
│   ├── General Scripts/     # Theme and general utilities
│   ├── Installer Scripts/   # Software installation scripts
│   ├── Sandbox Configurations/  # .wsb configuration files
│   └── Startup Scripts/     # Sandbox initialization
├── Setup.ps1                # Main setup/installation script
├── Microsoft.PowerShell_profile.ps1  # PowerShell profile
└── WindowsTweaks.reg        # Registry tweaks
```

## Testing & Build Commands

**Note:** This repository does NOT have a formal test suite or build process.

### Running Scripts

```powershell
# Run a script directly
.\Setup.ps1

# Run with parameters
.\Setup.ps1 -AcceptLicense -Force

# Run a specific script
.\powershell\git-user.ps1 -username myuser

# Test script syntax (without execution)
powershell -NoProfile -Command "& {Get-Command -Syntax '.\Setup.ps1'}"

# Validate PowerShell syntax
$null = [System.Management.Automation.Language.Parser]::ParseFile(".\Setup.ps1", [ref]$null, [ref]$null)
```

### Manual Testing

Since there are no automated tests, manually test scripts by:
1. Running them in a test environment (Windows Sandbox recommended)
2. Verifying expected behavior with various parameter combinations
3. Checking error handling with invalid inputs
4. Testing with `-WhatIf` parameter where applicable

## Code Style Guidelines

### File Structure & Headers

All PowerShell scripts should include:
- Comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`)
- Author attribution and last updated date
- License information (MIT License, Copyright 2023-2025 Federico Rapetti)

Example:
```powershell
<#
.SYNOPSIS
Brief description of what the script does.

.DESCRIPTION
Detailed description of functionality.

.PARAMETER paramName
Description of the parameter.

.EXAMPLE
.\script.ps1 -paramName value
#>

# Script purpose
# Author: fuji97
# Last Updated: August 14, 2025

param(
    [Parameter(Mandatory=$true)]
    [string]$paramName
)
```

### Parameters

- Use proper parameter attributes: `[Parameter(Mandatory=$true, Position=0)]`
- Include `HelpMessage` for mandatory parameters
- Use descriptive parameter names with proper casing (e.g., `$AcceptLicense`, `$DisplayName`)
- Use `[switch]` for boolean flags
- Use typed parameters (`[string]`, `[int]`, `[SecureString]`)

### Naming Conventions

- **Functions:** Use PowerShell verb-noun pattern with PascalCase (e.g., `Install-WithWinget`, `Test-WingetInstalled`)
- **Variables:** Use camelCase for local variables (e.g., `$profilePath`, `$installArgs`)
- **Constants/Hashtables:** Use PascalCase (e.g., `$Colors`, `$git_configs`)
- **Parameters:** Use PascalCase (e.g., `$PackageId`, `$DisplayName`)
- **Files:** Use PascalCase with hyphens (e.g., `Install-VSCode.ps1`, `git-user.ps1`)

### Output & Messages

Use `Write-Host` with color coding for user-facing messages:
- **Green (`$Colors.Success`):** Success messages
- **Yellow (`$Colors.Warning`):** Warnings and important notices
- **Cyan (`$Colors.Info`):** Informational messages
- **Magenta (`$Colors.Header`):** Section headers
- **Red (`$Colors.Error`):** Error messages (use `Write-Error` for exceptions)

Example:
```powershell
$Colors = @{
    Header = "Magenta"
    Success = "Green"
    Warning = "Yellow"
    Info = "Cyan"
    Error = "Red"
}

Write-Host "Installing component..." -ForegroundColor $Colors.Info
Write-Host "Installation successful!" -ForegroundColor $Colors.Success
```

### Error Handling

- Use `try/catch` blocks for operations that may fail
- Check `$LASTEXITCODE` after external command execution
- Return boolean values from functions to indicate success/failure
- Provide helpful error messages with context
- Use `Write-Error` for errors, `Write-Warning` for non-critical issues

Example:
```powershell
try {
    $result = & winget @installArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Success!" -ForegroundColor Green
        return $true
    } else {
        Write-Error "Failed with exit code: $LASTEXITCODE"
        return $false
    }
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    return $false
}
```

### Code Organization

- Define helper functions before main execution
- Group related functionality into functions
- Use clear section separators with comments
- Place main execution logic at the bottom
- Extract common functionality into shared files (e.g., `Common.ps1`)

### Best Practices

1. **Avoid hardcoded paths:** Use `$PSScriptRoot`, `$env:USERPROFILE`, environment variables
2. **Use `Join-Path`:** For path construction instead of string concatenation
3. **Parameter splatting:** Use `@()` arrays for building command arguments
4. **Null handling:** Redirect errors with `2>$null` or `| Out-Null` when appropriate
5. **Exit codes:** Use `exit 1` for errors, `exit 0` for success in standalone scripts
6. **Execution policy:** Be mindful that scripts may need `Set-ExecutionPolicy` adjustments
7. **Compatibility:** Target both Windows PowerShell 5.1+ and PowerShell Core 7+
8. **Registry operations:** Use `reg add` commands with `/f` flag for non-interactive execution
9. **External tools:** Check for tool availability before use (e.g., `Test-WingetInstalled`)
10. **Remote execution:** Support remote execution via `irm` (Invoke-RestMethod) where applicable

### Comments

- Use `#` for single-line comments
- Use `<# #>` for multi-line comments and documentation blocks
- Comment complex logic, registry tweaks, and workarounds
- Include links to relevant documentation or issues when referencing fixes

### Classes

When using PowerShell classes:
```powershell
class User {
    [string]$name
    [string]$email
    [string]$signingkey
}

$config = [User]@{
    name = "User Name"
    email = "user@mail.com"
}
```

### Formatting

- **Indentation:** 4 spaces (no tabs)
- **Line length:** Keep lines under 120 characters when reasonable
- **Braces:** Opening brace on same line, closing brace on new line
- **Spacing:** Space after commas, around operators
- **Empty lines:** Use to separate logical sections

## Windows Sandbox Specifics

When working with Windows Sandbox scripts:
- Use `$launchingSandbox` switch parameter to control first-run behavior
- Include registry tweaks for sandbox environment optimization
- Map host folders in `.wsb` configuration files
- Use `C:\Users\WDAGUtilityAccount\Desktop\HostShared` as the standard shared folder path
- Set execution policy to `Unrestricted` for sandbox environment
- Include refreshExplorer (`Stop-Process -Name explorer -Force`) after registry changes

## Common Patterns

### Installing with Winget
```powershell
Install-WithWinget -PackageId "Microsoft.WindowsTerminal" -DisplayName "Windows Terminal" -AcceptLicense:$AcceptLicense
```

### Checking prerequisites
```powershell
if (-not (Test-WingetInstalled)) {
    Write-Error "Winget is required"
    exit 1
}
```

### Downloading from GitHub
```powershell
$url = "https://raw.githubusercontent.com/fuji97/scripts/main/file.ps1"
$content = (New-Object System.Net.WebClient).DownloadString($url)
```

## Important Notes

- Always test in Windows Sandbox before modifying system-level scripts
- Preserve backward compatibility with existing installations
- Document any new dependencies or prerequisites
- Follow MIT License requirements for new code
- Credit original authors (ThioJoe for Windows Sandbox tools)
- Update "Last Updated" date when modifying scripts
- Avoid emojis in code except for user-facing output (✨, ❌ are acceptable)
