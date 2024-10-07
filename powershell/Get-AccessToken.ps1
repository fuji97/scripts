<#
.SYNOPSIS
    Obtains an OAuth 2.0 access token from a specified OAuth2 provider and copies it to the clipboard.

.DESCRIPTION
    This PowerShell script obtains an OAuth 2.0 access token using the credentials of an application registered with an OAuth2 provider and copies it to the clipboard.
    It requires the token endpoint URL, client ID, client secret, and scope as parameters.

.PARAMETER tokenUrl
    The URL of the OAuth2 token endpoint.

.PARAMETER clientId
    The client ID of the application registered with the OAuth2 provider.

.PARAMETER clientSecret
    The client secret of the application registered with the OAuth2 provider.

.PARAMETER scope
    The scope for which to request the access token.

.EXAMPLE
    .\Get-AccessToken.ps1 -tokenUrl "https://example.com/oauth2/token" -clientId "your-client-id" -clientSecret "your-client-secret" -scope "your-scope"

.NOTES
    Ensure you have the necessary permissions to run this script and that the provided credentials are correct.
#>

param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$tokenUrl,

    [Parameter(Position = 1, Mandatory = $true)]
    [string]$clientId,

    [Parameter(Position = 2, Mandatory = $true)]
    [string]$clientSecret,

    [Parameter(Position = 3, Mandatory = $true)]
    [string]$scope
)

# Create the request body
$body = @{
    client_id     = $clientId
    scope         = $scope
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}

# Perform the REST method to obtain the token
$response = Invoke-RestMethod -Method Post -Uri $tokenUrl -ContentType "application/x-www-form-urlencoded" -Body $body

# Extract the access token from the response
$accessToken = $response.access_token

# Output the access token
Write-Output $accessToken

# Copy to clipboard
Set-Clipboard $accessToken

Write-Output "`nAccess token copied to clipboard"
