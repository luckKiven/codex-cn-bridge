# Codex CN Bridge - 测试连接
# 用法：/codex-cn-bridge test

$ErrorActionPreference = "SilentlyContinue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Codex CN Bridge - 连接测试" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 测试健康检查
Write-Host "[1/3] 测试健康检查..." -ForegroundColor Yellow
try {
    $Response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 5 -UseBasicParsing
    $Health = $Response.Content | ConvertFrom-Json
    Write-Host "[✓] 服务正常：$($Health.status)" -ForegroundColor Green
    Write-Host "    已加载模型：$($Health.models_loaded)" -ForegroundColor Cyan
} catch {
    Write-Host "[!] 健康检查失败：$_" -ForegroundColor Red
    Write-Host ""
    Write-Host "请运行 '/codex-cn-bridge start' 启动服务" -ForegroundColor Cyan
    exit 1
}

Write-Host ""

# 测试模型列表
Write-Host "[2/3] 获取模型列表..." -ForegroundColor Yellow
try {
    $Response = Invoke-WebRequest -Uri "http://localhost:3000/v1/models" -TimeoutSec 5 -UseBasicParsing
    $Models = $Response.Content | ConvertFrom-Json
    Write-Host "[✓] 可用模型：" -ForegroundColor Green
    foreach ($model in $Models.data) {
        Write-Host "    - $($model.id)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "[!] 获取模型列表失败：$_" -ForegroundColor Red
}

Write-Host ""

# 测试实际调用
Write-Host "[3/3] 测试模型调用..." -ForegroundColor Yellow
try {
    $Body = @{
        model = "qwen3.5-plus"
        input = "测试"
        stream = $false
    } | ConvertTo-Json
    
    $Response = Invoke-WebRequest -Uri "http://localhost:3000/responses" -Method POST -Body $Body -ContentType "application/json" -TimeoutSec 30 -UseBasicParsing
    $Result = $Response.Content | ConvertFrom-Json
    
    if ($Result.status -eq "completed") {
        Write-Host "[✓] 模型调用成功" -ForegroundColor Green
        Write-Host "    回复：$($Result.output.Substring(0, [Math]::Min(50, $Result.output.Length)))..." -ForegroundColor Cyan
    } else {
        Write-Host "[!] 模型调用异常：$($Result.status)" -ForegroundColor Red
    }
} catch {
    Write-Host "[!] 模型调用失败：$_" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能原因：" -ForegroundColor Yellow
    Write-Host "  1. API Key 未配置或无效" -ForegroundColor Gray
    Write-Host "  2. 网络连接问题" -ForegroundColor Gray
    Write-Host "  3. 模型服务不可用" -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  测试完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
