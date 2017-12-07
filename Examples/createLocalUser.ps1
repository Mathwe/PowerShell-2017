#Name:  Create Local User
#Purpose: To create a local user on a domain joined computer, Specificly to avoid a block by microsoft.
#Version: 0.1
#Creator: Matthew Winrich
#Created: 11-21-17

$user = $null
$user = get-LocalUser -Name "ITADMIN" -ErrorAction SilentlyContinue

if ( $user -eq $null ) {
    new-localuser -Name ITADMIN -Description "Local Admin on computer for mantinance" -Password (ConvertTo-SecureString -String "P@ssword" -AsPlainText -Force)
    Write-Output "Created Local User ITADMIN"
}
else {
    Write-Output "User ITADMIN Already Exists, Not Created"
}
