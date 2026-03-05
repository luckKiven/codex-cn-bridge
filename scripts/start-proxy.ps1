# Codex CN Bridge - Start Proxy Service
# Usage: /codex-cn-bridge start

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$SkillDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $SkillDir
$ProxyDir = "$env:USERPROFILE\.codex\cn-bridge"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Codex CN Bridge - Protocol Converter" -ForegroundColor Cyan
Write-Host "  Use Domestic AI Models with Codex" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check config directory
if (-not (Test-Path $ProxyDir)) {
    Write-Host "[*] Creating config directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $ProxyDir | Out-Null
}

# Check .env file
$EnvFile = "$env:USERPROFILE\.codex\cn-bridge.env"
if (-not (Test-Path $EnvFile)) {
    Write-Host ""
    Write-Host "[!] Config file not found: $EnvFile" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please configure API Key (choose one):" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Method 1: Create .env file" -ForegroundColor Cyan
    Write-Host "  $EnvFile" -ForegroundColor Gray
    Write-Host "  Content:" -ForegroundColor Gray
    Write-Host "  QWEN_API_KEY=sk-your-alibaba-cloud-key" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Method 2: Set environment variable" -ForegroundColor Cyan
    Write-Host "  [System.Environment]::SetEnvironmentVariable('QWEN_API_KEY', 'sk-your-key', 'User')" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Check Python
try {
    $PythonCmd = Get-Command python -ErrorAction Stop
    Write-Host "[OK] Python installed: $($PythonCmd.Source)" -ForegroundColor Green
} catch {
    Write-Host "[!] Python not found, please install Python 3.8+" -ForegroundColor Red
    exit 1
}

# Check dependencies
Write-Host "[*] Checking dependencies..." -ForegroundColor Yellow
try {
    python -c "import fastapi, uvicorn, httpx, yaml, dotenv" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Missing packages"
    }
    Write-Host "[OK] Dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "[*] Installing dependencies..." -ForegroundColor Yellow
    pip install fastapi uvicorn httpx pyyaml python-dotenv -q
    Write-Host "[OK] Dependencies installed" -ForegroundColor Green
}

# Deploy proxy script to config directory
Write-Host "[*] Deploying proxy service..." -ForegroundColor Yellow
Copy-Item "$SkillDir\src\proxy.py" "$ProxyDir\proxy.py" -Force
Copy-Item "$SkillDir\config\models.yaml" "$ProxyDir\models.yaml" -Force

# Check port usage
$Port = 3000
$ExistingProcess = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($ExistingProcess) {
    Write-Host "[!] Port $Port already in use (PID: $($ExistingProcess.OwningProcess))" -ForegroundColor Red
    Write-Host "    Run '/codex-cn-bridge stop' to stop old process" -ForegroundColor Yellow
    exit 1
}

# Load environment variables
Write-Host "[*] Loading environment variables..." -ForegroundColor Yellow
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -notmatch "^#" -and $_ -match "=") {
            $key, $value = $_.Split("=", 2)
            [System.Environment]::SetEnvironmentVariable($key.Trim(), $value.Trim(), "Process")
        }
    }
}

# Start service
Write-Host ""
Write-Host "[OK] Starting proxy service..." -ForegroundColor Green
Write-Host "    Listening: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "    Config: $EnvFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop service" -ForegroundColor Yellow
Write-Host ""

Set-Location $ProxyDir
python proxy.py
