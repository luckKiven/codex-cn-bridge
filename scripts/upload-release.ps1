# GitHub Releases 上传脚本
# 用法：.\upload-release.ps1

$ErrorActionPreference = "Stop"

$Repo = "luckKiven/codex-cn-bridge"
$Token = Read-Host "Enter GitHub PAT (Personal Access Token)"
$ZipPath = "C:\Users\14015\.openclaw\workspace\skills\codex-cn-bridge.zip"
$TagName = "v1.0.0"
$ReleaseName = "v1.0.0 - Initial Release"
$Description = @"
Codex CN Bridge v1.0.0 - 让 Codex 使用国内 AI 模型

功能：
- 协议转换（Responses API → Chat Completions）
- 支持 5 个国内模型（Qwen、Kimi、GLM）
- 一键启动/停止/测试
- 流式响应支持

安装：
git clone https://github.com/luckKiven/codex-cn-bridge.git
"@

# Create release
Write-Host "[*] Creating release..." -ForegroundColor Yellow
$Headers = @{
    "Authorization" = "token $Token"
    "Content-Type" = "application/json"
    "User-Agent" = "PowerShell"
}

$Body = @{
    tag_name = $TagName
    name = $ReleaseName
    body = $Description
    draft = $false
    prerelease = $false
} | ConvertTo-Json

$ReleaseUrl = "https://api.github.com/repos/$Repo/releases"
$Response = Invoke-RestMethod -Uri $ReleaseUrl -Method Post -Headers $Headers -Body $Body

Write-Host "[OK] Release created: $($Response.html_url)" -ForegroundColor Green

# Upload asset
Write-Host "[*] Uploading asset..." -ForegroundColor Yellow
$UploadUrl = "$($Response.upload_url)?name=codex-cn-bridge.zip"
$UploadUrl = $UploadUrl -replace '\{.*\}', ''

$FileBytes = [System.IO.File]::ReadAllBytes($ZipPath)
$ContentType = "application/zip"

$Headers["Content-Type"] = $ContentType
$Headers["Content-Length"] = $FileBytes.Length

Invoke-RestMethod -Uri $UploadUrl -Method Post -Headers $Headers -Body $FileBytes

Write-Host "[OK] Asset uploaded!" -ForegroundColor Green
Write-Host ""
Write-Host "Release URL: $($Response.html_url)" -ForegroundColor Cyan
