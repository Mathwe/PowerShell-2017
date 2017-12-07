

function importList ($importFile) {
    $list = import-csv $importFile

    return $list
}