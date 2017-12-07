<#
.SYNOPSIS
Get-DiskInventory Retrieves logical disk information from one or more computer.
.DESCRIPTION
Get-DiskInventory uses WMI to retrieve the WIN32_LogicalDisk instances from on eor more computers.  It displays each disk's drive letter, free space, total size, and percentage of free space.
.PARAMETER computername
The computer name, or names, to query. Default: Localhost
.PARAMETER drivetype
The drive type to query.  Se win32_logicaldisk documentation for values. 3 is a fixed disk, and is the default.
.EXAMPLE
Get-DiskInventory -computername MW-DC1 -drivetype 3
#>
[cmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [alias('hostname')]
    [string]$computername,
    [ValidateSet (2,3)]
    [int]$drivetype = 3
)


Write-Verbose "Connecting to $computername"
Write-Verbose "Looking for drive type $drivetype"
Get-WmiObject -Class Win32_LogicalDisk `
    -ComputerName $computername `
    -Filter "drivetype=$drivetype" |
    Sort-Object -Property DeviceID | 
    Format-Table -Property DeviceID,
    @{name='FreeSpace(MB)';expression={$_.FreeSpace / 1MB -as [int]}},
    @{name='Size(GB';expression={$_.size /1GB -as [int]}},
    @{name='%Free';expression={$_.FreeSpace / $_.size * 100 -as [int]}}
Write-Verbose "Finished Running Command"