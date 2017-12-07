

function getMemorySize() {
    get-ciminstance Win32_PhysicalMemory | Select-Object -Property @{name='Capacity(GB)';expression={$_.Capacity / 1GB}}
}

getMemorySize