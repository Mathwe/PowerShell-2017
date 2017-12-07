function main {
    write-output "Hello World"
    writePI
    $returned=returnTrue
    Write-Output "$returned"
    Write-Output (returnTrue)
    Write-Output "Hello`n`t$returned`nPlease Work" | writeInput
}

function writePI {
    write-output "3.14"
}

function returnTrue {
    return "Frank"
}
function writeInput {
    Write-Output "$input"
#    Write-Output "$input" | out-file C:\scripts\functionTest.txt
    #Write-Output "$input" | out-file C:\scripts\functionTest.txt
    ##write-output "$input"
}

function writeReport() {
    function writeOut() {
        #$date=Get-Date
   #     Write-Output "$input" #| write-host
        Write-Output "$input" | Out-File -FilePath "C:\scripts\PleaseWork.txt"
    }
    write-output "Writing Report" | write-host
    $header="****************************************"
    $header
    Write-Output "$header" | writeOut
    Write-Output "$header`n`t`tReport of Computer $currentName`n$header" | writeOut

}

main