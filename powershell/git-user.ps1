<#
.SYNOPSIS
Sets git configurations for a given username.

.DESCRIPTION
This script sets git configurations for a given username by mapping the username to a User object that contains the name, email, and signingkey properties.

.PARAMETER username
The username to set git configurations for.

.EXAMPLE
.\git-user.ps1 -username user

This example sets git configurations for the username "user".
#>

# Read input username from program argument
param (
    [Parameter(Mandatory=$true, Position=0, HelpMessage="The username to set git configurations for.")]
    [string]$username
)

# Define a User object to hold git configurations
class User {
    [string]$name
    [string]$email
    [string]$signingkey
}

# Map of usernames to git configurations
$git_configs = @{
    "user" = [User]@{
        name = "User Name"
        email = "user@mail.com"
        signingkey = "1234567890ABCDEF"
    }
}

# Check if the input username exists in the map
if ($git_configs.ContainsKey($username)) {
    # Set git configurations using the mapped value
    $config = $git_configs[$username]
    git config --local user.name $config.name
    git config --local user.email $config.email
    git config --local user.signingkey $config.signingkey
    Write-Host "✨ Git configurations set for $username"
} else {
    Write-Host "❌ No git configurations found for $username"
}