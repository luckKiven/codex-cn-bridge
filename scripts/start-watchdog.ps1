# Codex CN Bridge - Start Watchdog (Background Monitor)
# Usage: /codex-cn-bridge watchdog

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Codex CN Bridge - Watchdog Monitor" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WatchdogScript = "$ScriptDir\watchdog.ps1"

if (-not (Test-Path $WatchdogScript)) {
    Write-Host "[!] Watchdog script not found: $WatchdogScript" -ForegroundColor Red
    exit 1
}

# Check if already running
$WatchdogProcess = Get-Process | Where-Object { 
    $_.ProcessName -eq "powershell" -and 
    $_.CommandLine -like "*watchdog.ps1*" 
} -ErrorAction SilentlyContinue

if ($WatchdogProcess) {
    Write-Host "[i] Watchdog already running (PID: $($WatchdogProcess.Id))" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Tips:" -ForegroundColor Cyan
    Write-Host "  Status: /codex-cn-bridge watchdog-status" -ForegroundColor Gray
    Write-Host "  Stop: /codex-cn-bridge watchdog-stop" -ForegroundColor Gray
    exit 0
}

# Start watchdog in background
Write-Host "[*] Starting watchdog..." -ForegroundColor Yellow

$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$StartInfo.FileName = "powershell.exe"
$StartInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$WatchdogScript`""
$StartInfo.WorkingDirectory = $ScriptDir
$StartInfo.UseShellExecute = $true
$StartInfo.WindowStyle = "Hidden"
$StartInfo.CreateNoWindow = $true

try {
    $Process = [System.Diagnostics.Process]::Start($StartInfo)
    Start-Sleep -Seconds 3
    
    $NewProcess = Get-Process | Where-Object { 
        $_.Id -eq $Process.Id 
    } -ErrorAction SilentlyContinue
    
    if ($NewProcess) {
        Write-Host "[OK] Watchdog started (PID: $($Process.Id))" -ForegroundColor Green
        Write-Host ""
        Write-Host "Monitor Info:" -ForegroundColor Cyan
        Write-Host "  Port: 3000" -ForegroundColor Gray
        Write-Host "  Check Interval: 30s" -ForegroundColor Gray
        Write-Host "  Health Check: 300s" -ForegroundColor Gray
        Write-Host "  Log: $env:USERPROFILE\.codex\cn-bridge\watchdog.log" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor Cyan
        Write-Host "  Status: /codex-cn-bridge watchdog-status" -ForegroundColor Gray
        Write-Host "  Logs: /codex-cn-bridge watchdog-logs" -ForegroundColor Gray
        Write-Host "  Stop: /codex-cn-bridge watchdog-stop" -ForegroundColor Gray
    } else {
        Write-Host "[!] Failed to start watchdog" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[!] Error starting watchdog: $_" -ForegroundColor Red
    exit 1
}
