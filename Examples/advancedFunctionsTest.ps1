##Test Advanced function

$validationSet = Get-Content C:\scripts\Examples\validationSet.txt

function testFunction () {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$computername = 'localhost',
        [Parameter(Mandatory=$true)]
        [ValidateSet('automatice','manual','disabled')]
        [string]$starttype = 'disabled'
    )

    Write-Output "`$computername: $computername, `$starttype: $starttype"

}

testFunction -computername localhost