$workingComputer="172.26.117.140"
$workingCred=Get-Credential

function getFeatures() {
   $osType=invoke-command -scriptblock {Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty ProductType}  -ComputerName $workingComputer -Credential $workingCred
   switch ($osType) {
        '1' {
            write-output "Computer is Workstation"
            $installedFeatures=invoke-command -scriptblock {Get-CimInstance Win32_OptionalFeature -Filter "InstallState like '1'" | select-object -Property Name,InstallState} -ComputerName $workingComputer -Credential $workingCred

        }
        '2' {
            Write-Output "Computer is Domain Controler"
            $installedFeatures=invoke-command -scriptblock {Get-WindowsFeature | Where-Object {$_.Installed -eq $true} | select -Property DisplayName,Name} -ComputerName $workingComputer -Credential $workingCred | Format-Table Name,DisplayName
        }
        '3' {
            Write-Output "Computer is Server"
            $installedFeatures=invoke-command -scriptblock {Get-WindowsFeature | Where-Object {$_.Installed -eq $true} | select -Property DisplayName,Name} -ComputerName $workingComputer -Credential $workingCred | Format-Table Name,DisplayName
        }
        default {
            Write-Output "Error: Unknown Computer type"
        }
   }
   return $installedFeatures
}

write-output (getFeatures)