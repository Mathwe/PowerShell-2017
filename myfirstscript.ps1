##myfirstscript.ps1
##Purpose: Output LOCALHOST Services and IP ADDRESS to a text file
##Created By: Matthew Winrich
##Created On: Sept 28, 2017
##
##How to use: Run script from current location
##and it will creaate a file in C:\scripts.  C:\scripts needs to exist to function

$header="*************************************" 
$endfile="***********`nEnd of File`n***********"

$intIndex = (Get-NetIPAddress | where {$_.InterfaceAlias -like "Ethernet*"} | Select-Object -ExpandProperty InterfaceIndex)
$getIP = Get-NetIPAddress -InterfaceIndex $intIndex | Select-Object -ExpandProperty IPAddress
$getGateway = Get-NetRoute | where {$_.DestinationPrefix -eq "0.0.0.0/0" } | Select-Object -ExpandProperty NextHop
$ipProtocol = "IPv4"
$getDNS =  Get-DnsClientServerAddress -InterfaceIndex $intIndex | Select-Object -ExpandProperty ServerAddresses
Out-File -filepath C:\scripts\MyFirstScript_Output.txt

##Get running Services
Write-Output "$header`n`t  Running Services`n$header" | Out-File -FilePath C:\scripts\MyFirstScript_Output.txt -Append
Get-Service | Where-Object {$_.Status -eq "Running"} | Format-Table -AutoSize -Wrap | Out-File -FilePath C:\scripts\MyFirstScript_Output.txt -Append

##Get Network Information
write-output "$header`n`tNetwork Configuration`n$header" | Out-File -FilePath C:\scripts\MyFirstScript_Output.txt -Append
Write-Output "IP Address: $getIP" | Out-File -FilePath C:\scripts\MyFirstScript_Output.txt -Append
Write-Output "DNS Server: $getDNS" | Out-File -FilePath C:\scripts\MyFirstScript_Output.txt -Append
Write-output "GateWay:    $getGateway" | Out-File -FilePath C:\scripts\MyFirstScript_Output.txt -Append

#End File
Write-Output `n$endfile | Out-File -FilePath C:\scripts\MyFirstScript_Output.txt -Append