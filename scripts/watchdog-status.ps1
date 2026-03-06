# Codex CN Bridge - Watchdog Status
# Usage: /codex-cn-bridge watchdog-status

$ErrorActionPreference = "SilentlyContinue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Codex CN Bridge - Watchdog Status" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check watchdog
$WatchdogProcesses = Get-Process | Where-Object { 
    $_.ProcessName -eq "powershell" -and 
    $_.CommandLine -like "*watchdog.ps1*" 
} -ErrorAction SilentlyContinue

if ($WatchdogProcesses) {
    Write-Host "[OK] Watchdog running" -ForegroundColor Green
    foreach ($Proc in $WatchdogProcesses) {
        Write-Host "    PID: $($Proc.Id)" -ForegroundColor Gray
        Write-Host "    Started: $($Proc.StartTime)" -ForegroundColor Gray
        Write-Host "    Uptime: $((Get-Date) - $Proc.StartTime)" -ForegroundColor Gray
    }
} else {
    Write-Host "[X] Watchdog not running" -ForegroundColor Red
}

Write-Host ""

# Check qwen-proxy service
$Port = 3000
$Connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue

if ($Connection) {
    $Pid = $Connection.OwningProcess | Select-Object -First 1
    $Process = Get-Process -Id $Pid -ErrorAction SilentlyContinue
    
    Write-Host "[OK] qwen-proxy service running (port $Port)" -ForegroundColor Green
    Write-Host "    PID: $Pid" -ForegroundColor Gray
    if ($Process) {
        Write-Host "    Process: $($Process.ProcessName)" -ForegroundColor Gray
        Write-Host "    Started: $($Process.StartTime)" -ForegroundColor Gray
    }
} else {
    Write-Host "[X] qwen-proxy service not running" -ForegroundColor Red
}

Write-Host ""

# Show recent logs
$LogPath = "$env:USERPROFILE\.codex\cn-bridge\watchdog.log"
if (Test-Path $LogPath) {
    Write-Host "Recent logs (last 10):" -ForegroundColor Cyan
    Get-Content $LogPath -Tail 10 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
} else {
    Write-Host "Log file not found: $LogPath" -ForegroundColor Gray
}

Write-Host ""
