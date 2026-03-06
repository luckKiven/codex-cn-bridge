# Codex CN Bridge - Watchdog Logs
# Usage: /codex-cn-bridge watchdog-logs [-Lines 50] [-Follow]

param(
    [int]$Lines = 50,
    [switch]$Follow
)

$LogPath = "$env:USERPROFILE\.codex\cn-bridge\watchdog.log"

if (-not (Test-Path $LogPath)) {
    Write-Host "Log file not found: $LogPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Tip: Log file will be created when watchdog first runs" -ForegroundColor Cyan
    exit 0
}

if ($Follow) {
    Write-Host "Following logs (Ctrl+C to exit):" -ForegroundColor Cyan
    Write-Host ""
    Get-Content $LogPath -Wait -Tail $Lines -Encoding UTF8
} else {
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "  Codex CN Bridge - Watchdog Logs" -ForegroundColor Cyan
    Write-Host "  File: $LogPath" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    
    Get-Content $LogPath -Tail $Lines -Encoding UTF8 | ForEach-Object {
        if ($_ -match "\[ERROR\]") {
            Write-Host $_ -ForegroundColor Red
        } elseif ($_ -match "\[WARN\]") {
            Write-Host $_ -ForegroundColor Yellow
        } elseif ($_ -match "\[HEALTH\]") {
            Write-Host $_ -ForegroundColor Cyan
        } else {
            Write-Host $_ -ForegroundColor Gray
        }
    }
}
