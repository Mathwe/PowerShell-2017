function main () {   
    #Prompt for Student name and assign to variable 
    #The out-file path has to exist on your system somewhere.  You can save it where you wish 
    $Student=Read-Host "Enter Name of Student" 
    $outputPath="C:\scripts\Server Final\$Student.txt"
    #clear the output file if it exists
    Out-File -FilePath $outputPath
    #Header 
    write-output "**************************************************************************" | writeOut 
    write-output "******** $Student Domain Report *******************************************"| writeOut 
    write-output "**************************************************************************" | writeOut 
    #Line Breaks 
    write-output "" | writeOut 
    write-output "" | writeOut 
    write-output "" | writeOut 
    #Header 
    write-output "***********$Student User Report*******************************************" | writeOut 
    #should display 75 users based on previous labs 
    #required attributes to display: Distinguishedname,homedirectory,company 
    $userCount=(get-aduser -filter * -SearchBase "OU=Corp,DC=mw,DC=local" -Properties Distinguishedname,homedirectory,company).count
    Write-Output "Total Number of Users: $userCount" | writeOut
    (get-aduser -filter * -SearchBase "OU=Corp,DC=mw,DC=local" -Properties Distinguishedname,homedirectory,company | Select-Object -Property Distinguishedname,homedirectory,company) | writeOut

    write-output "" | writeOut 
    write-output "" | writeOut 
    write-output "" | writeOut 
    write-output "***********$Student Security Group **************************************" | writeOut 
    #should display 8 Security Groups based on previous labs 
    #required attributes to display: Name,members
    $groupCount=(Get-ADGroup -Filter * -SearchBase "OU=Corp,DC=mw,DC=local" -Properties Name,members).count
    Write-Output "Total Number of Groups: $groupCount" | writeOut
    #(Get-ADGroup -Filter * -SearchBase "OU=Corp,DC=mw,DC=local" -Properties Name,members | Format-Table -Property Name,@{name='Members';expression={Write-Output  "$(Get-ADGroupMember -Identity $_.Name | Select-Object -Property Samaccountname)"}} -Wrap) | writeOut
    $groups=(Get-ADGroup -Filter * -SearchBase "OU=Corp,DC=mw,DC=local" | Select-Object -ExpandProperty Name)
    Write-Output "" | writeOut
    Write-Output "Group   Members" | writeOut
    Write-Output "-----   -------" | writeOut
    foreach ($group in $groups) {
        Write-Output "$group" | writeOut
        $members=(Get-ADGroupMember -Identity $group | Select-Object -ExpandProperty Samaccountname)
        foreach ($member in  $members) {
            Write-Output "       $member" | writeOut
        }
    }

    write-output "" | writeOut 
    write-output "" | writeOut 
    write-output "" | writeOut 
    write-output "***********$Student Domain Structure (Organizational Unit) ***************" | writeOut 
    #should display 9 OUs (including Corp) 
    #required attributes to display: Name 
    $ouCount=(Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Corp,DC=mw,DC=local").count
    Write-Output "Total Number of OUs: $ouCount" | writeOut
    (Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Corp,DC=mw,DC=local" | Select-Object -Property Name) | writeOut

    write-output "" | writeOut 
    write-output "" | writeOut 
    write-output "" | writeOut 
    write-output "***********$Student File System (Home folders and Departmental Folders) Report**********************" | writeOut 
    #should display 8 departmental folders 
    #should display 75 home folders 
    #example to be modified for your file system
    $userDIRCount=(Get-ChildItem \\MW-DC1\home).count 
    $corpDIRCount=(Get-ChildItem \\MW-DC1\Corp).count 
    Write-Output "Number of DIRs in Home: $userDIRCount" | writeOut
    Write-Output "Number of DIRs in Corp: $corpDIRCount" | writeOut
    get-childitem \\MW-DC1\home  | get-acl | Select-Object path,accesstostring | Format-List | writeOut 
    get-childitem \\MW-DC1\Corp  | get-acl | Select-Object path,accesstostring | Format-List | writeOut 
    #required attributes to display: Path,accesstostring  
    
    #Server/System Report will retrieve/list the following: 
    #System name 
    #System IP
    #Installed Roles (Servers only) 
    #System RAM 
    Write-Output "*********** $Student System  Report **********************" | writeOut
    $domainServers=getDomainServers
    
    foreach ($server in $domainServers) {
        getServerInfo($server)
    }
    Write-Output "" | writeOut
    Write-Output "*********** End of Report ***********" | writeOut
}

function getDomainServers () {
    Get-ADComputer -Filter * -Properties OperatingSystem,Name | Where-Object { $_.OperatingSystem -match "server" } | Select-Object -ExpandProperty Name
}
function getServerInfo ($currentServer) {
    $ip=$null
    $roles=$null
    $mem=$null
    write-output "" | writeOut
    write-output "******* Current Server is $currentServer *******" | writeOut
    Write-Output "" | writeOut
    $ip=Invoke-Command -ComputerName $currentServer -ScriptBlock {Get-NetIPAddress | Where-Object { $_.IPAddress -match "^[0-9]{2,3}.\d{2,3}.\d{2,3}.\d{2,3}"} | Select-Object -ExpandProperty IPAddress}
     #>
    Write-Output "$currentServer's IP is:  $ip" | writeOut
    Write-Output "" | writeOut
    $roles=Invoke-Command -ComputerName $currentServer -ScriptBlock {Get-WindowsFeature | Where-Object { $_.Installed -eq $true}}
    Write-Output "Currently installed Roles on $currentServer" | writeOut
    Write-Output $roles | writeOut
    Write-Output "" | writeOut
    $mem=(Get-WmiObject -Class win32_physicalmemory -ComputerName $currentServer | Select-Object -ExpandProperty Capacity)
    Write-Output "RAM Capacity on ${currentServer}: $($mem/1GB)(GB)" | writeOut
    Write-Output "" | writeOut
    Write-Output "******* End of $currentServer Report *******" | writeOut
    Write-Output "" | writeOut
    
}
function writeOut () {
    $input | Out-File -FilePath $outputPath -Append
}
main