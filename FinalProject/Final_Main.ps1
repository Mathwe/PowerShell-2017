﻿#Name: Main Powershell Final File
#Purpose: To audit remote systems for information
#Version: 0.1
#Creator: Matthew Winrich
#Created: 11/09/2017

<#
.SYNOPSIS
Final_Main.ps1 gathers and creates reports on specified computers
.DESCRIPTION
Final_Main.ps1 queries computers specifed in a csv file for computer information.  Then queries active directory for user information.
.PARAMETER OutputDirectory
The directory to write reports to.
.PARAMETER InputFile
The file that contains the computer names, ips, usernames, and passwords.
.PARAMETER RunBye
The name of the person running the script.
.EXAMPLE
Final_Main.ps1 -OutputDirectory C:\Scripts\FinalProject\Output -InputFile C:\Scripts\FinalProject\Final_Input.csv -RunBy "Matt Win"
#>
[cmdletBinding()]

param (
    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory = $(throw "OutpuDirectory option is required"),
    [Parameter( Mandatory = $true)]
    [string]$InputFile = $(throw "InputFile option is required"),
    [parameter(Mandatory = $true)]
    [string]$RunBy = $(throw "A username is required to run.")
)

function Main () {
    initOutputFolder($OutputDirectory)
    $computerList=importList($InputFile)
    foreach ($computer in $computerList) {
        $date=Get-Date
        $currentName=($computer.computername)
        $currentIP=$computer.ip
        $currentUser=$computer.username
        $currentPass=(ConvertTo-SecureString $computer.passwd -AsPlainText -Force)
        $currentCred=createCred
        $outputFilePath="$($OutputDirectory)\$($currentName)-Inv-$($date.Month)-$($date.Day)-$($date.Year).txt"

        write-output "Current Computer is: $currentName"
        $isOnline=isConnected($currentIP)
        #If computer is offline drop this iteration of the for loop and start the next.
        if ($isOnline -eq 'False') {
            continue
        }

        
        $midtermReport=getInfoMid
        $finalReport=getInfoFinal
        writeReportToFile
        #cleanUpVariables
      #  clearAllVariables
    }
    $midterReport

}

function getInfoMid () {
    #midterm info
    $runningUser=("$env:USERDOMAIN\$env:USERNAME")
    $currentName=getHostname($currentIP)
    $OSVersion=getOSInfo
    $processorInfo=getProcessor
    $RAMvolume=getMemorySize
    $rolesFeatures=getFeatures
    $remoteStatus=getRDStatus
    $systemLog=getSystemLog
    $appLog=getAppLog

    #formatReportMid
    Write-Verbose "Writing Report"
    $reportMid=writeReportMid
    return $reportMid
}

function getInfoFinal () {
    #final info
    [boolean]$ADModulePresent=isADModulePresent
    $ADPath="OU=Students,OU=Users,OU=GBNetworkLabs,DC=gbnetworklabs,DC=local"
    if ( $ADModulePresent -eq $true ) {
        $usersLastLogon=(get-aduser -Filter * -Properties DisplayName,LastLogonDate -SearchBase $ADPath -ErrorAction SilentlyContinue | Select-Object -Property DisplayName,LastLogonDate | sort -Property DisplayName)
        $usersLastPassChange=(get-aduser -Filter * -Properties DisplayName,PasswordLastSet -SearchBase $ADPath -ErrorAction SilentlyContinue | Select-Object -Property DisplayName,PasswordLastSet | sort -Property DisplayName)
    }
    else {
        $usersLastLogon="ActiveDirectory module not found, Active Directory could not be queried"
        $usersLastPassChange="ActiveDirectory module not found, Active Directory could not be queried"
    }

    #formatReportFinal
    $reportFinal=writeReportFinal
    return $reportFinal
}

function writeReportMid () {
    #write the midterm report to the mid report variable.
    $header="****************************************"
    Write-Output "$header"# | writeOut
    Write-Output "`tReport of Computer `"$currentName`""# | writeOut
    Write-Output "$header"# | writeOut
    Write-Output "Current time is: $((get-date).Hour):$((get-date).Minute):$((get-date).Second)"# | writeOut
    Write-Output "Report Run By: $runBy"
    Write-Output "Report Run As: $runningUser"
    Write-Output ""# | WriteOut
    Write-Output "$header"# | writeOut
    Write-Output "Computer is Online: $isOnline"# | writeOut
    Write-Output "Computer Name is: $currentName"# | writeOut
    Write-Output "$header"# | writeOut
    #Write-Output "" #| writeOut
    Write-Output ""# | writeOut
    Write-Output "$header"# | writeOut
    Write-Output "OS Version"# | writeOut
    Write-Output "$header"# | writeOut
    $OSVersion | Format-Table -Wrap # | writeOut
    #Write-Output ""# | writeOut
    #Write-Output ""# | writeOut
    Write-Output "$header"# | writeOut
    Write-Output "Processor Information"# | writeOut
    Write-Output "$header"# | writeOut
    $processorInfo | Format-Table -Wrap # | writeOut
    #Write-Output ""# | writeOut
    #Write-Output ""# | writeOut
    Write-Output "$header"# | writeOut
    Write-Output "Memory Volume is: $($RAMVolume | Select-Object -ExpandProperty 'Capacity(GB)') GB"# | writeOut
    write-output "$header"# | writeOut
    #Write-Output ""# | writeOut
    Write-Output ""# | writeOut
    Write-Output "$header"# | writeOut
    Write-Output "Currently Installed Roles and/or Features"# | writeOut
    Write-Output "$header"# | writeOut
    Write-Output $rolesFeatures #| writeOut
    Write-Output ""# | writeOut
    #Write-Output ""# | writeOut
    Write-Output "$header"# | writeOut
    Write-Output "Remote Desktop is: $remoteStatus"# | writeOut
    Write-Output "$header"# | writeOut
    #Write-Output ""# | writeOut
    Write-Output ""#  | writeOut
    Write-Output "$header"# | writeOut
    Write-Output "System Log, Top 5 Errors and Warnings"# | writeOut
    Write-Output "$header"# | writeOut
    $systemLog | format-table -Property Index,Time,EntryType,Source,InstanceID -Wrap # | writeOut
    #Write-Output ""# | writeOut
    #Write-Output ""# | writeOut
    Write-Output "$header"# | writeOut
    Write-Output "Application Log, Top 5 Errors and Warnings"# | writeOut
    Write-Output "$header"# | writeOut
    $appLog | Format-Table -Property Index,Time,EntryType,Source,InstanceID -Wrap # | writeOut
    Write-Output ""
    Write-Output ""

}

function writeReportFinal () {
    #Format the new data pulled for the final project
    $header="****************************************"

    Write-Output $header
    Write-Output "Last Logon Date of AD Users"
    Write-Output $header
    Write-Output $usersLastLogon | Format-Table
    Write-Output ""
    Write-Output $header
    Write-Output "Last Password Change of AD Users"
    Write-Output $header
    Write-Output $usersLastPassChange | Format-Table
    Write-Output ""
}

function writeReportToFile () {
    #writes all the gathered information to a variable in a decent format
    Write-Output "Clearing Output File" | Write-Host
    $outputFilePath
    Out-File -FilePath $outputFilePath 


    write-output "Writing Report" | write-host
    write-Output $midtermReport | writeOut
    Write-Output $finalReport | writeOut
    Write-Output "" | writeOut
    Write-Output "" | writeOut
    Write-Output "End of File" | writeOut

}
function writeReportOld() {
    #writes all the gathered information to a variable in a decent format
    $header="****************************************"
    Write-Output "Clearing Output File" | Write-Host
    $outputFilePath
    Out-File -FilePath $outputFilePath 


    write-output "Writing Report" | write-host
    Write-Output "$header" | writeOut
    Write-Output "`tReport of Computer `"$currentName`"" | writeOut
    Write-Output "$header" | writeOut
    Write-Output "Current time is: $((get-date).Hour):$((get-date).Minute):$((get-date).Second)" | writeOut
    Write-Output "" | WriteOut
    Write-Output "$header" | writeOut
    Write-Output "Computer is Online: $isOnline" | writeOut
    Write-Output "Computer Name is: $currentName" | writeOut
    Write-Output "$header" | writeOut
    Write-Output ""| writeOut
    Write-Output ""| writeOut
    Write-Output "$header" | writeOut
    Write-Output "OS Version" | writeOut
    Write-Output "$header" | writeOut
    $OSVersion | Format-Table -Wrap | writeOut
    Write-Output ""| writeOut
    Write-Output ""| writeOut
    Write-Output "$header" | writeOut
    Write-Output "Processor Information" | writeOut
    Write-Output "$header" | writeOut
    $processorInfo | Format-Table -Wrap| writeOut
    Write-Output ""| writeOut
    Write-Output ""| writeOut
    Write-Output "$header" | writeOut
    Write-Output "Memory Volume is: $($RAMVolume | Select-Object -ExpandProperty 'Capacity(GB)') GB" | writeOut
    write-output "$header" | writeOut
    Write-Output ""| writeOut
    Write-Output ""| writeOut
    Write-Output "$header" | writeOut
    Write-Output "Currently Installed Roles and/or Features" | writeOut
    Write-Output "$header" | writeOut
    Write-Output $rolesFeatures | writeOut
    Write-Output ""| writeOut
    Write-Output ""| writeOut
    Write-Output "$header" | writeOut
    Write-Output "Remote Desktop is: $remoteStatus" | writeOut
    Write-Output "$header" | writeOut
    Write-Output ""| writeOut
    Write-Output ""| writeOut
    Write-Output "$header" | writeOut
    Write-Output "System Log, Top 5 Errors and Warnings" | writeOut
    Write-Output "$header" | writeOut
    $systemLog | format-table -Property Index,Time,EntryType,Source,InstanceID -Wrap | writeOut
    Write-Output ""| writeOut
    Write-Output ""| writeOut
    Write-Output "$header" | writeOut
    Write-Output "Application Log, Top 5 Errors and Warnings" | writeOut
    Write-Output "$header" | writeOut
    $appLog | Format-Table -Property Index,Time,EntryType,Source,InstanceID -Wrap | writeOut

}

function isADModulePresent () {
    Import-Module ActiveDirectory
    $ADModuleStatus=((Get-Module ActiveDirectory) -ne $null)
    return $ADModuleStatus
}
function initOutputFolder ($folder) {
    #Checks for the existance of the specified output folder, if it doesn't exist it will be created if possible.
    Write-Output "Checking for existance of folder '$folder'" | write-host
    $doesExist=doesExistpath($folder)
    if ( $doesExist -eq $false ) {
        Write-Output "Folder '$folder' doesn't exist, creating it" | write-host
        $created=New-Item -Path $folder -ItemType Directory
        if ( $created -ne $null ) {
            write-output "Created folder '$folder'" | write-host
            
        }
        else {
            write-output "Error Encountered creating '$folder' Exiting" | write-host
            exit
        }
    }
    else {
        Write-Output "Folder '$folder' does exist, Moving On." | write-host
    }
}

function importList ($importFile) {
    $list = import-csv $importFile

    return $list
}

function createCred() {
    Write-Output "Creating Credential for user $currentUser" | Write-Host
    #Creates a credential using the username and password specified in the input file.
    $cred=new-object -TypeName System.Management.Automation.PSCredential -ArgumentList $currentUser,$currentPass
    return $cred
}

function isConnected ($address) {
    #Uses test-connection to see if computer is online before generating report.  Tests 5 times at 15 second intervals
    #until the system responds, if it doesn't respond the computer is marked as offline.
    for ($count=1; $count -le 5;$count++) {
        $isConnected=test-connection -count 2 $address -Quiet
        if ($isConnected -eq $false) {
            Write-Output "Connection Test $count Failed, Trying Again" | Write-Host
            Start-Sleep -Seconds 15
        }
        else {
            break
        }
    }
    if ($isConnected -eq $false) {
        out-file -FilePath $outputFilePath 
        write-output "Computer is Not Online, Skipping over" | Write-Host
        Write-Output "****************************" | writeOut
        write-output "Computer `"$currentName`" is Offline" | writeOut
        Write-Output "****************************" | writeOut
        $isConnected="False"
    }
    else {
        Write-Output "Computer is Online, Continuing" | Write-Host
        $isConnected="True"
    }
    return $isConnected
}

function getHostname ($address) {
    #Gets the hostname of the computer from the "Win32_SystemAccount" cim object.
    $hostnameWIP = (Invoke-Command -ScriptBlock { Get-CimInstance Win32_SystemAccount | Select-Object -ExpandProperty Domain -First 1 } -ComputerName $address  -Credential $currentCred)
    #Checks that the hostname of the computer matches the hostname given in the input file.
    if ($hostnameWIP -eq $currentName) {
        Write-Output "Current Computer is $currentName" | Write-Host
    }
    elseif ($hostnameWIP -eq $null) {
        write-output "Computer Hostname could not be retrived, using name in file" | write-host
    }
    else {
        Write-Output "ComputerName in input file doesn't match IP!" | Write-Host
        Write-Output "Using name $hostnameWIP instead" | Write-Host
    }
    return $hostnameWIP

}

function getOSInfo() {
    Write-Output "Collecting OS Version Information" | write-host
    #Get the OS Version information from the cim object "Win32_OperatingSystem"
    $osInfo=invoke-command -scriptblock {Get-CimInstance Win32_OperatingSystem | Select-Object -Property @{name='OS Name';expression={$_.Caption}},Version} -ComputerName $currentIP -Cred $currentCred | select -Property "OS Name",Version
    return $osInfo
    #$osInfo
}

function getProcessor() {
    Write-output "Collecting Processor Version Information" | write-host
    #Get the information pertaining to the processor from the cim object "Win32_Processor"
    invoke-command -scriptblock {Get-CimInstance Win32_Processor -Property Name,NumberofCores,Manufacturer | Format-Table -Property @{name='Processor Name';expression={$_.Name}},@{name='Number of Cores';expression={$_.NumberofCores}},Manufacturer} -ComputerName $currentIP -Credential $currentCred
}

function getMemorySize() {
    Write-Output "Collecting Memory Size Information" | write-host
    #Use the cim object "Win32_PhysicalMemory" to determine the amount of physical memory in the system.
    invoke-command -scriptblock {get-ciminstance Win32_PhysicalMemory | Select-Object -Property @{name='Capacity(GB)';expression={$_.Capacity / 1GB}}} -ComputerName $currentIP -Credential $currentCred
}

function getFeatures() {
   write-output "Getting Roles and Features" | write-host
   #Determine the type of OS running on the computer.(Server or not)
   $osType=invoke-command -scriptblock {Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty ProductType}  -ComputerName $currentIP -Credential $currentCred
   #Collect the currently installed Roles and Features depentding upon the OS type.
   switch ($osType) {
        '1' {
            write-output "Computer is Workstation" | write-host
            $installedFeatures=invoke-command -scriptblock {Get-CimInstance Win32_OptionalFeature -Filter "InstallState like '1'" | select-object -Property Name,InstallState} -ComputerName $currentIP -Credential $currentCred
            $installedFeatures=($installedFeatures | Select-Object -Property Name)

        }
        '2' {
            Write-Output "Computer is Domain Controler" | write-host
            $installedFeatures=invoke-command -scriptblock {Get-WindowsFeature | Where-Object {$_.Installed -eq $true} | select-object -Property DisplayName,Name} -ComputerName $currentIP -Credential $currentCred | Format-Table Name,DisplayName
        }
        '3' {
            Write-Output "Computer is Server" | write-host
            $installedFeatures=invoke-command -scriptblock {Get-WindowsFeature | Where-Object {$_.Installed -eq $true} | Select-Object -Property DisplayName,Name} -ComputerName $currentIP -Credential $currentCred | Format-Table Name,DisplayName
        }
        default {
            Write-Output "Error: Unknown Computer type" | write-host
            $installedFeatures="Error: Unknown Computer Type"
        }
   }
   return $installedFeatures
}

function getRDStatus(){
    write-output "Checking Remote Desktop Status" | write-host
    #Check the registy to see if Remote Desktop Connetions are accepted.  Reg Key fdenyTSConnections
    $RDStatus=invoke-command -scriptBlock {Get-ItemProperty -Path 'HKLM:\system\CurrentControlSet\control\Terminal Server\' -Name fdenyTSConnections | select-object -Expandproperty fDenyTSConnections} -ComputerName $currentIP -Credential $currentCred
    if ( $RDStatus -eq '0' ) {
        Write-Output "Remote Desktop is Enabled" | write-host
        return "Enabled"
    }
    elseif ($RDStatus -eq '1') {
        Write-Output "Remote Desktop is Disabled" | write-host
        return "Disabled"
    }
}

function getSystemLog {
    write-output "Getting System Logs" | write-host
    #Get the 5 Newest Warnings and the 5 Newest Errors in the System log.
    $systemLogE=invoke-command -scriptblock {get-eventlog -LogName System -Newest 5 -EntryType Error} -ComputerName $currentIP -Credential $currentCred
    $systemLogW=Invoke-Command -scriptblock {get-eventlog -LogName System -Newest 5 -EntryType Warning} -ComputerName $currentIP -Credential $currentCred
    return $systemLogE,$systemLogW
}

function getAppLog {
    Write-Verbose "Getting Application Logs"
    #Gets the 5 newest warnings and the 5 newest errors in the application log.
    Write-Verbose "Getting Newest Errors in Application Log"
    $appLogE=invoke-command -scriptblock {Get-EventLog -LogName Application -Newest 5 -EntryType Error -ErrorAction SilentlyContinue} -ComputerName $currentIP -Credential $currentCred
    Write-Verbose "Getting Newest Warnings in Application Log"
    $appLogW=invoke-command -scriptblock {Get-EventLog -LogName Application -Newest 5 -EntryType Warning -ErrorAction SilentlyContinue} -ComputerName $currentIP -Credential $currentCred
    if ( $appLogE -eq $null) {
        $appLogE = "No Errors in Application Log"
    }
    if ( $appLogW -eq $null ) {
        $applogW = "No Warnings in Application Log"
    }
    return $appLogE,$appLogW
}

 function writeOut() {
        #Write the piped input to the specified output file.
        $input | Out-File -FilePath $outputfilePath -Append
}

function doesExistPath($filepath) {
    $exists=test-path -Path $filepath
    return $exists
}

main