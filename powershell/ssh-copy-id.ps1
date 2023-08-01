param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$publicKey,

    [Parameter(Position = 1, Mandatory = $true)]
    [string]$remoteHost,

    [Parameter(Position = 2, Mandatory = $false)]
    [SecureString]$password
)

# Read the contents of the public key file
$publicKeyContent = Get-Content $publicKey

# Create the .ssh directory on the remote host if it doesn't exist
if ($password) {
    Invoke-Expression "ssh $remoteHost  'mkdir -p ~/.ssh'"
} else {
    Invoke-Expression "ssh $remoteHost 'mkdir -p ~/.ssh'"
}

# Copy the public key to the remote host's authorized_keys file
Invoke-Expression "echo '$publicKeyContent' | ssh $username@$remoteHost 'cat >> ~/.ssh/authorized_keys'"

Write-Host "SSH key copied to the remote host ($remoteHost) for user ($username)."
Write-Host "You should now be able to SSH to the remote host without a password."

