

function doesExistPath($filepath) {
    $exists=test-path -Path $filepath
    return $exists
}

doesExistPath("C:\scripts")