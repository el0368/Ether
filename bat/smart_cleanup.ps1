# Smart Cleanup Script for Ether IDE
# Only kills processes that are specifically related to this project folder.

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ProjectName = "Ether"

Write-Host "[Smart Cleanup] Project: $ProjectRoot"

# 1. Kill processes holding ports 4000 and 5173
$ports = @(4000, 5173)
foreach ($port in $ports) {
    $connections = netstat -ano | Select-String ":$port " | Select-String "LISTENING"
    foreach ($conn in $connections) {
        $parts = $conn -split '\s+'
        $procId = $parts[-1]
        if ($procId -match '^\d+$' -and $procId -ne '0') {
            try {
                $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
                if ($proc) {
                    # Check if this process is related to our project
                    $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $procId" -ErrorAction SilentlyContinue).CommandLine
                    if ($cmdLine -match $ProjectName -or $cmdLine -match "mix" -or $cmdLine -match "vite" -or $cmdLine -match "bun") {
                        Write-Host "  Killing $($proc.Name) (PID: $procId) on port $port"
                        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
                    }
                }
            } catch {}
        }
    }
}

# 2. Kill orphaned BEAM processes from THIS project
Get-Process -Name "beam.smp", "erl", "epmd" -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)" -ErrorAction SilentlyContinue).CommandLine
        if ($cmdLine -match $ProjectName) {
            Write-Host "  Killing orphaned $($_.Name) (PID: $($_.Id))"
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    } catch {}
}

# 3. Kill orphaned ether.exe (Tauri app)
Get-Process -Name "ether" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  Killing orphaned ether.exe (PID: $($_.Id))"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Write-Host "[Smart Cleanup] Done."
