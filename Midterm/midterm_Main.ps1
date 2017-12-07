#Name: Main Powershell Midterm File
#Purpose: To audit remote systems for information
#Version: 0.1
#Creator: Matthew Winrich
#Created: 10/12/2017

param (
    [string]$OutputDirectory = $(throw "OutpuDirectory option is required"),
    [string]$InputFile = $(throw "InputFile option is required")
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
        if ($isOnline -eq 'False') {
            continue
        }
        $currentName=getHostname($currentIP)
        $OSVersion=getOSInfo
        $processorInfo=getProcessor
        $RAMvolume=getMemorySize
        $rolesFeatures=getFeatures
        $remoteStatus=getRDStatus
        $systemLog=getSystemLog
        $appLog=getAppLog
        #writeLog
        writeReport
    }

}

function writeReport() {
    
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

function initOutputFolder ($folder) {
    Write-Output "Checking for existance of folder '$folder'" | write-host  ##Debug Line
    $doesExist=doesExistpath($folder)
    if ( $doesExist -eq $false ) {
        Write-Output "Folder '$folder' doesn't exist, creating it" | write-host  ##Debug Line
        $created=New-Item -Path $folder -ItemType Directory
        if ( $created -ne $null ) {
            write-output "Created folder '$folder'" | write-host
            
        }
        else {
            write-output "Error Encountered Exiting" | write-host
            exit
        }
    }
    else {
        Write-Output "Folder '$folder' does exist, Moving On." | write-host  ##Debug Line
    }
}

function importList ($importFile) {
    $list = import-csv $importFile

    return $list
}

function createCred() {
    Write-Output "Creating Credential for user $currentUser" | Write-Host
    $cred=new-object -TypeName System.Management.Automation.PSCredential -ArgumentList $currentUser,$currentPass
    return $cred
}

function isConnected ($address) {
    for ($count=1; $count -le 5;$count++) {
        $isConnected=test-connection -count 2 $address -Quiet
        if ($isConnected -eq $false) {
            Write-Output "Connection Test $count Failed, Trying Again" | Write-Host
            Start-Sleep -Seconds 15
            #$isConnected | write-host
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
    $hostnameWIP = (Invoke-Command -ScriptBlock { Get-CimInstance Win32_SystemAccount | Select-Object -ExpandProperty Domain -First 1 } -ComputerName $address  -Credential $currentCred)
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
    $osInfo=invoke-command -scriptblock {Get-CimInstance Win32_OperatingSystem | Select-Object -Property @{name='OS Name';expression={$_.Caption}},Version} -ComputerName $currentIP -Cred $currentCred | select -Property "OS Name",Version
    return $osInfo
    #$osInfo
}

function getProcessor() {
    Write-output "Collecting Processor Version Information" | write-host
    invoke-command -scriptblock {Get-CimInstance Win32_Processor -Property Name,NumberofCores,Manufacturer | Format-Table -Property @{name='Processor Name';expression={$_.Name}},@{name='Number of Cores';expression={$_.NumberofCores}},Manufacturer} -ComputerName $currentIP -Credential $currentCred
}

function getMemorySize() {
    Write-Output "Collecting Memory Size Information" | write-host
    invoke-command -scriptblock {get-ciminstance Win32_PhysicalMemory | Select-Object -Property @{name='Capacity(GB)';expression={$_.Capacity / 1GB}}} -ComputerName $currentIP -Credential $currentCred
}

function getFeatures() {
   write-output "Getting Roles and Features" | write-host
   $osType=invoke-command -scriptblock {Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty ProductType}  -ComputerName $currentIP -Credential $currentCred
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
    $systemLogE=invoke-command -scriptblock {get-eventlog -LogName System -Newest 5 -EntryType Error} -ComputerName $currentIP -Credential $currentCred
    $systemLogW=Invoke-Command -scriptblock {get-eventlog -LogName System -Newest 5 -EntryType Warning} -ComputerName $currentIP -Credential $currentCred
    return $systemLogE,$systemLogW
}

function getAppLog {
    Write-Output "Getting Application Logs" | Write-Host
    $appLogE=invoke-command -scriptblock {get-eventlog -LogName Application -Newest 5 -EntryType Error} -ComputerName $currentIP -Credential $currentCred
    $appLogW=invoke-command -scriptblock {Get-EventLog -LogName Application -Newest 5 -EntryType Warning} -ComputerName $currentIP -Credential $currentCred
    return $appLogE,$appLogW
}

 function writeOut() {
        #Write-Output "$input" | write-host
        $input | Out-File -FilePath $outputfilePath -Append
}

function doesExistPath($filepath) {
    $exists=test-path -Path $filepath
    return $exists
}

main