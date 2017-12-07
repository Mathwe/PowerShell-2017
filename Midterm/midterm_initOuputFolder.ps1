param([String]$OutputDirectory=$Null)


function initOutputFolder ($outputFolder) {
    Write-Output "Checking for existance of folder '$outputFolder'"  ##Debug Line
    $doesExist=doesExistpath($outputFolder)
    if ( $doesExist -eq $false ) {
        Write-Output "Folder '$outputFolder' doesn't exist, creating it"  ##Debug Line
        New-Item -Path $outputFolder -ItemType Directory > $Null
    }
    else {
        Write-Output "Folder '$outputFolder' does exist, Moving On."  ##Debug Line
    }
}



function doesExistPath($filepath) {
    $exists=test-path -Path $filepath
    return $exists
}
initOutputFolder($OutputDirectory)