# Codex CN Bridge - 停止代理服务
# 用法：/codex-cn-bridge stop

$ErrorActionPreference = "SilentlyContinue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Codex CN Bridge - 停止服务" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 查找并停止进程
$Port = 3000
$Process = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique

if ($Process) {
    Write-Host "[?] 找到运行中的服务 (PID: $Process)" -ForegroundColor Yellow
    
    foreach ($Pid in $Process) {
        try {
            $ProcInfo = Get-Process -Id $Pid -ErrorAction SilentlyContinue
            if ($ProcInfo -and $ProcInfo.ProcessName -eq "python") {
                Write-Host "[?] 停止进程 $Pid ($($ProcInfo.ProcessName))..." -ForegroundColor Yellow
                Stop-Process -Id $Pid -Force
                Write-Host "[✓] 已停止" -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] 无法停止进程 $Pid : $_" -ForegroundColor Red
        }
    }
    
    # 等待端口释放
    Start-Sleep -Seconds 2
    Write-Host ""
    Write-Host "[✓] 服务已停止" -ForegroundColor Green
} else {
    Write-Host "[i] 未发现运行中的服务" -ForegroundColor Gray
}

Write-Host ""
Write-Host "提示：运行 '/codex-cn-bridge start' 重新启动服务" -ForegroundColor Cyan
