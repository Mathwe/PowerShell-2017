$workingcomputer="MW-WS1"

function getConnected {
    $isConnected=test-connection $workingComputer -Quiet
    return $isConnected
}

$isConnected=getConnected
Write-Output $isConnected