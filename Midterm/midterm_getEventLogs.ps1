

function getSystemLog {
    $systemLogE=get-eventlog -LogName System -Newest 5 -EntryType Error
    $systemLogW=get-eventlog -LogName System -Newest 5 -EntryType Warning
}

function getAppLog {
    $appLogE=get-eventlog -LogName Application -Newest 5 -EntryType Error
    #Write-Output $appLogE
    $appLogW=Get-EventLog -LogName Application -Newest 5 -EntryType Warning
    return $appLogE,$appLogW
}

#getAppLog
$app=getAppLog
write-output $app