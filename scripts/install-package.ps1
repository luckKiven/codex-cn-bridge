# Codex CN Bridge - Install Complete Package from GitHub
# Usage: /codex-cn-bridge install

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Codex CN Bridge - Install Complete Package" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# GitHub repo
$Repo = "luckKiven/codex-cn-bridge"
$ReleaseUrl = "https://github.com/$Repo/archive/refs/heads/main.zip"
$TempDir = "$env:TEMP\codex-cn-bridge-install"
$TargetDir = "$env:USERPROFILE\.codex\cn-bridge"

# Check if git is available
try {
    $GitCmd = Get-Command git -ErrorAction Stop
    Write-Host "[OK] Git found: $($GitCmd.Source)" -ForegroundColor Green
} catch {
    Write-Host "[!] Git not found, please install Git first" -ForegroundColor Red
    Write-Host "    Download: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Create temp directory
Write-Host "[*] Creating temp directory..." -ForegroundColor Yellow
if (Test-Path $TempDir) {
    Remove-Item $TempDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

# Download from GitHub
Write-Host "[*] Downloading from GitHub..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $ReleaseUrl -OutFile "$TempDir\codex-cn-bridge.zip" -UseBasicParsing
    Write-Host "[OK] Download complete" -ForegroundColor Green
} catch {
    Write-Host "[!] Download failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Manually download from GitHub" -ForegroundColor Yellow
    Write-Host "  https://github.com/$Repo" -ForegroundColor Cyan
    exit 1
}

# Extract
Write-Host "[*] Extracting..." -ForegroundColor Yellow
Expand-Archive -Path "$TempDir\codex-cn-bridge.zip" -DestinationPath $TempDir -Force

# Copy to target directory
Write-Host "[*] Installing to $TargetDir..." -ForegroundColor Yellow
if (Test-Path $TargetDir) {
    Remove-Item $TargetDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

$SourceDir = Get-ChildItem "$TempDir\codex-cn-bridge-*" -Directory | Select-Object -First 1
Copy-Item "$SourceDir\src\*" "$TargetDir" -Recurse -Force
Copy-Item "$SourceDir\config\*" "$TargetDir" -Recurse -Force

# Cleanup
Write-Host "[*] Cleaning up..." -ForegroundColor Yellow
Remove-Item $TempDir -Recurse -Force

Write-Host ""
Write-Host "[OK] Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Configure API Key: ~/.codex/cn-bridge.env" -ForegroundColor Gray
Write-Host "  2. Start service: /codex-cn-bridge start" -ForegroundColor Gray
Write-Host ""
