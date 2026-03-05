# Codex CN Bridge - 检查服务状态
# 用法：/codex-cn-bridge status

$ErrorActionPreference = "SilentlyContinue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Codex CN Bridge - 服务状态" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 检查端口
$Port = 3000
$Process = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue

if ($Process) {
    Write-Host "[✓] 服务运行中" -ForegroundColor Green
    Write-Host "    端口：$Port" -ForegroundColor Cyan
    Write-Host "    PID: $($Process.OwningProcess)" -ForegroundColor Cyan
    
    # 测试健康检查
    try {
        $Response = Invoke-WebRequest -Uri "http://localhost:$Port/health" -TimeoutSec 5 -UseBasicParsing
        $Health = $Response.Content | ConvertFrom-Json
        Write-Host "    状态：$($Health.status)" -ForegroundColor Green
        Write-Host "    已加载模型：$($Health.models_loaded)" -ForegroundColor Cyan
    } catch {
        Write-Host "    健康检查：失败" -ForegroundColor Red
    }
} else {
    Write-Host "[!] 服务未运行" -ForegroundColor Red
    Write-Host ""
    Write-Host "运行 '/codex-cn-bridge start' 启动服务" -ForegroundColor Cyan
}

Write-Host ""

# 检查配置文件
$EnvFile = "$env:USERPROFILE\.codex\cn-bridge.env"
if (Test-Path $EnvFile) {
    Write-Host "[✓] 配置文件：$EnvFile" -ForegroundColor Green
} else {
    Write-Host "[!] 配置文件不存在：$EnvFile" -ForegroundColor Red
}

# 检查 Codex 配置
$CodexConfig = "$env:USERPROFILE\.codex\config.toml"
if (Test-Path $CodexConfig) {
    $Content = Get-Content $CodexConfig -Raw
    if ($Content -match "cn-bridge") {
        Write-Host "[✓] Codex 配置：已配置 cn-bridge" -ForegroundColor Green
    } else {
        Write-Host "[?] Codex 配置：未配置 cn-bridge" -ForegroundColor Yellow
    }
} else {
    Write-Host "[!] Codex 配置文件不存在" -ForegroundColor Red
}

Write-Host ""
