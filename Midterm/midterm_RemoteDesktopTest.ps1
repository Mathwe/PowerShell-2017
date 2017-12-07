
function getRDStatus(){
    write-output "Checking Remote Desktop Status" | write-host
    $RDStatus=invoke-command -scriptBlock {Get-ItemProperty -Path 'HKLM:\system\CurrentControlSet\control\Terminal Server\' -Name fdenyTSConnections | select-object -Expandproperty fDenyTSConnections} -ComputerName <#$currentIP#>localhost <#-Credential $currentCred#>
    if ( $RDStatus -eq '0' ) {
        Write-Output "Remote Desktop is Enabled" | write-host
        return "Enabled"
    }
    elseif ($RDStatus -eq '1') {
        Write-Output "Remote Desktop is Disabled" | write-host
        return "Disabled"
    }
}

getRDTest