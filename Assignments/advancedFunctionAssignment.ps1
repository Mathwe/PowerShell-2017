#Name:
#Purpose:
#Version: 0.1
#Creator: Matthew Winrich
#Created: Nov 02, 2017

$header='##################################################'
function getOSInfo () {
    param(
        [string]$computername = 'localhost'
    )

    $osInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $computername | Select-Object -Property BuildNumber,Caption,ServicePackMajorVersion
    write-output "$header `nOutput of getOSInfo Function `nArguments: `n computername: $computername `n$header" | Out-File -FilePath C:\scripts\advancedFunctionOutput.txt
    $osInfo | out-file -FilePath C:\scripts\advancedFunctionOutput.txt -Append
}

function getServices () {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$computername = 'localhost',
        [Parameter(Mandatory=$true)]
        [ValidateSet('automatic','manual','disabled')]
        [string]$starttype = 'disabled'
    )

    $services = Get-Service -ComputerName $computername | Where-Object {$_.StartType -eq "$starttype"} | Select-Object -Property Status,Name,StartType,DisplayName
    write-output "$header `nOutput of getServices Function `nArguments: `n computername: $computername `n starttype: $starttype `n$header" | Out-File -FilePath C:\scripts\advancedFunctionOutput.txt -Append
    $services | Out-File -FilePath C:\scripts\advancedFunctionOutput.txt -Append

}

getOSInfo -computername MW-C1
getServices -computername MW-C1 -starttype manual