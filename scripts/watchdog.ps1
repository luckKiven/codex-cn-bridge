# Codex CN Bridge - Watchdog Daemon
# Monitors qwen-proxy service, auto-restarts on failure
# Usage: .\watchdog.ps1

param(
    [int]$CheckInterval = 30,
    [int]$HealthCheckInterval = 300,
    [string]$LogPath = "$env:USERPROFILE\.codex\cn-bridge\watchdog.log",
    [switch]$AsBackground
)

$ErrorActionPreference = "Continue"
$Port = 3000
$ServiceName = "qwen-proxy"
$StartTime = Get-Date

# Ensure log directory exists
$LogDir = Split-Path -Parent $LogPath
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
}

# Log function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { Write-Host $LogEntry -ForegroundColor Green }
        "WARN" { Write-Host $LogEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $LogEntry -ForegroundColor Red }
        "HEALTH" { Write-Host $LogEntry -ForegroundColor Cyan }
    }
    
    Add-Content -Path $LogPath -Value $LogEntry -Encoding UTF8
}

# Check if service is running
function Test-ServiceRunning {
    try {
        $Connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue -State Listen
        if ($Connections) {
            $Pid = $Connections[0].OwningProcess
            if ($Pid -and $Pid -gt 0) {
                $Process = Get-Process -Id $Pid -ErrorAction SilentlyContinue
                if ($Process) {
                    return @{
                        Running = $true
                        Pid = $Pid
                        ProcessName = $Process.ProcessName
                        StartTime = $Process.StartTime
                    }
                }
            }
        }
        
        # Fallback - test HTTP endpoint
        try {
            $Response = Invoke-WebRequest -Uri "http://localhost:$Port/health" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
            if ($Response.StatusCode -eq 200) {
                return @{ Running = $true; Pid = $null; ProcessName = "unknown"; StartTime = $null }
            }
        } catch {
        }
        
        return @{ Running = $false }
    } catch {
        return @{ Running = $false }
    }
}

# Start proxy service
function Start-ProxyService {
    Write-Log "Starting $ServiceName service..." "INFO"
    
    $ProxyDir = "$env:USERPROFILE\.codex\cn-bridge"
    $EnvFile = "$env:USERPROFILE\.codex\cn-bridge.env"
    $SkillDir = "G:\openClaw\xiaoxia\skills\codex-cn-bridge"
    
    if (-not (Test-Path $EnvFile)) {
        Write-Log "Config file not found: $EnvFile" "ERROR"
        return $false
    }
    
    try {
        $PythonCmd = Get-Command python -ErrorAction Stop
        Write-Log "Python found: $($PythonCmd.Source)" "INFO"
    } catch {
        Write-Log "Python not found" "ERROR"
        return $false
    }
    
    if (Test-Path "$SkillDir\src\proxy.py") {
        Copy-Item "$SkillDir\src\proxy.py" "$ProxyDir\proxy.py" -Force
        Copy-Item "$SkillDir\config\models.yaml" "$ProxyDir\models.yaml" -Force
        Write-Log "Deployed proxy.py and models.yaml" "INFO"
    }
    
    try {
        $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $StartInfo.FileName = "python"
        $StartInfo.Arguments = "proxy.py"
        $StartInfo.WorkingDirectory = $ProxyDir
        $StartInfo.UseShellExecute = $false
        $StartInfo.CreateNoWindow = $true
        
        # Copy current environment
        $CurrentEnv = [System.Environment]::GetEnvironmentVariables()
        foreach ($Key in $CurrentEnv.Keys) {
            if ($StartInfo.EnvironmentVariables.ContainsKey($Key)) {
                $StartInfo.EnvironmentVariables[$Key] = $CurrentEnv[$Key]
            } else {
                $StartInfo.EnvironmentVariables.Add($Key, $CurrentEnv[$Key])
            }
        }
        
        # Load env file and override
        if (Test-Path $EnvFile) {
            Get-Content $EnvFile | ForEach-Object {
                if ($_ -notmatch "^#" -and $_ -match "=") {
                    $parts = $_.Split("=", 2)
                    if ($parts.Length -eq 2) {
                        $key = $parts[0].Trim()
                        $value = $parts[1].Trim()
                        if ($StartInfo.EnvironmentVariables.ContainsKey($key)) {
                            $StartInfo.EnvironmentVariables[$key] = $value
                        } else {
                            $StartInfo.EnvironmentVariables.Add($key, $value)
                        }
                    }
                }
            }
        }
        
        Write-Log "Starting python proxy.py in $ProxyDir" "INFO"
        $Process = New-Object System.Diagnostics.Process
        $Process.StartInfo = $StartInfo
        $Started = $Process.Start()
        
        if (-not $Started) {
            Write-Log "Failed to start process" "ERROR"
            return $false
        }
        
        Start-Sleep -Seconds 5
        
        $Status = Test-ServiceRunning
        if ($Status.Running) {
            $PidInfo = if ($Status.Pid) { "PID: $($Status.Pid)" } else { "PID: unknown" }
            Write-Log "$ServiceName service started ($PidInfo)" "INFO"
            return $true
        } else {
            Write-Log "Service not detected after 5s, process exited: $($Process.HasExited)" "ERROR"
            return $false
        }
    } catch {
        Write-Log "Error starting service: $_" "ERROR"
        return $false
    }
}

# Stop proxy service
function Stop-ProxyService {
    Write-Log "Stopping $ServiceName service..." "INFO"
    
    $Status = Test-ServiceRunning
    if ($Status.Running -and $Status.Pid) {
        try {
            Stop-Process -Id $Status.Pid -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Write-Log "Service stopped" "INFO"
            return $true
        } catch {
            Write-Log "Error stopping service: $_" "ERROR"
            return $false
        }
    }
    return $true
}

# Health check
function Invoke-HealthCheck {
    Write-Log "Executing health check..." "HEALTH"
    
    try {
        $Response = Invoke-WebRequest -Uri "http://localhost:$Port/" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($Response.StatusCode -eq 200) {
            Write-Log "Health check passed" "HEALTH"
            return $true
        } else {
            Write-Log "Health check failed - status: $($Response.StatusCode)" "WARN"
            return $false
        }
    } catch {
        Write-Log "Health check failed - no response" "ERROR"
        return $false
    }
}

# Send alert
function Send-Alert {
    param([string]$Message)
    Write-Log "ALERT: $Message" "ERROR"
}

# Main loop
function Start-Watchdog {
    Write-Log "============================================" "INFO"
    Write-Log "  $ServiceName Watchdog Started" "INFO"
    Write-Log "  Port: $Port" "INFO"
    Write-Log "  Check Interval: $CheckInterval seconds" "INFO"
    Write-Log "  Health Check: $HealthCheckInterval seconds" "INFO"
    Write-Log "============================================" "INFO"
    Write-Log ""
    
    $LastHealthCheck = Get-Date
    $RestartCount = 0
    
    while ($true) {
        try {
            $Status = Test-ServiceRunning
            
            if (-not $Status.Running) {
                Write-Log "Service not running, attempting restart..." "WARN"
                Send-Alert "$ServiceName stopped, restarting"
                
                $RestartCount++
                
                if (Start-ProxyService) {
                    Write-Log "Service restarted successfully" "INFO"
                } else {
                    Write-Log "Service restart failed, retry next cycle" "ERROR"
                    Send-Alert "$ServiceName restart failed"
                }
            } else {
                $TimeSinceHealthCheck = (Get-Date) - $LastHealthCheck
                if ($TimeSinceHealthCheck.TotalSeconds -ge $HealthCheckInterval) {
                    if (-not (Invoke-HealthCheck)) {
                        Write-Log "Health check failed, restarting..." "WARN"
                        Stop-ProxyService
                        Start-Sleep -Seconds 3
                        Start-ProxyService
                    }
                    $LastHealthCheck = Get-Date
                }
            }
            
            Start-Sleep -Seconds $CheckInterval
            
        } catch {
            Write-Log "Monitor loop error: $_" "ERROR"
            Start-Sleep -Seconds 10
        }
    }
}

Start-Watchdog
