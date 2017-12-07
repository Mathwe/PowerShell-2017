$workingcomputer='172.26.117.140'
$workingcred = (Get-Credential)
function getHostname {
    $hostWIP = (Invoke-Command -ScriptBlock { Get-CimInstance Win32_SystemAccount | Select-Object -ExpandProperty Domain -First 1 } -ComputerName $workingcomputer  -Credential $workingcred)
    return $hostWIP

}

$hostname=getHostname
write-output `n$hostname