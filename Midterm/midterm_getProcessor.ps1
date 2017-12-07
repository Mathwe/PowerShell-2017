
function getProcessor() {
    Get-CimInstance Win32_Processor | Format-Table -Property @{name='Processor Name';expression={$_.Name}},@{name='Number of Cores';expression={$_.NumberofCores}},Manufacturer
}

getProcessor | Write-Output