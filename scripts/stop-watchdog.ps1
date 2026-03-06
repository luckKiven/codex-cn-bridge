# Codex CN Bridge - Stop Watchdog
# Usage: /codex-cn-bridge watchdog-stop

$ErrorActionPreference = "SilentlyContinue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Codex CN Bridge - Stop Watchdog" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$WatchdogProcesses = Get-Process | Where-Object { 
    $_.ProcessName -eq "powershell" -and 
    $_.CommandLine -like "*watchdog.ps1*" 
} -ErrorAction SilentlyContinue

if ($WatchdogProcesses) {
    Write-Host "[?] Found $($WatchdogProcesses.Count) watchdog process(es):" -ForegroundColor Yellow
    
    foreach ($Proc in $WatchdogProcesses) {
        try {
            Write-Host "    Stopping process $($Proc.Id)..." -ForegroundColor Gray
            Stop-Process -Id $Proc.Id -Force
            Write-Host "    [OK] Stopped" -ForegroundColor Green
        } catch {
            Write-Host "    [!] Failed to stop process $($Proc.Id): $_" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "[OK] Watchdog stopped" -ForegroundColor Green
} else {
    Write-Host "[i] No watchdog process found" -ForegroundColor Gray
}

Write-Host ""
