

function getOperatingSystemInfo() {
    $osInfo=Get-CimInstance Win32_OperatingSystem | Select-Object -Property @{name='OS Name';expression={$_.Caption}},Version
    return $osInfo
}

#getOperatingSystemInfo

Write-Output "`nOperating System Version `n   #################"
getOperatingSystemInfo
##getOperatingSystemInfo | Select-Object -Property @{name='OS';expression={$_.name -split ("|")}},Version
