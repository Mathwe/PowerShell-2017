<#
.SYNOPSIS
Get-PhysicalAdapters Retrives information about physical network adapters on system
.DESCRIPTION
Get-PhysicalAdapters uses WMI to retive the MacAddress, AdapterType, DeviceID, Name, and Speed of present physical network adapters.
.PARAMETER computername
The computer name, or names, to query.
.EXAMPLE
.\Get-PhysicalAdapters -computername localhost
#>

param (
    [Parameter(Mandatory=$true)]
    [Alias('hostname')]
    [string]$computername
)

Write-Verbose "Connecting to $computername and retriving adapter information"
Get-WmiObject win32_networkadapter -ComputerName $computername | where { $_.PhysicalAdapter } | select MACAddress,AdapterType,DeviceID,Name,Speed
Write-Verbose "Information Retrived"