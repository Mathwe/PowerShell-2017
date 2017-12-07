<#
.SYNOPSIS
Get-DiskInventory Retrieves logical disk information from one or more computer.
.DESCRIPTION
Get-DiskInventory uses WMI to retrieve the WIN32_LogicalDisk instances from one or more computers that have less then a specific percentage of free space.  It displays each disk's drive letter, free space, total size, and percentage of free space.
.PARAMETER computername
The computer name, or names, to query. Default: Localhost
.PARAMETER minPercent
Minimum amount of free space to avoid getting tagged
.EXAMPLE
Get-DiskInventory -computername MW-DC1 -minimumPercentageFree 25
#>

param (
    $computername = 'localhost',
    $minPercent = '10'
)


Get-WmiObject -Class Win32_LogicalDisk `
    -ComputerName $computername `
    -Filter "drivetype=3" |
    Where-Object { ($_.FreeSpace / $_.Size) -lt $minPercent/100 } |
    Select-Object -Property DeviceID,
    @{name='Freespace(MB)' ;expression={ $_.Freespace / 1MB -as [int] }},
    @{name='Size(GB)' ;expression={ $_.Size / 1GB -as [int] }}