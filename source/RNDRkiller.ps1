# === CONFIGURATION ===
$cpuThreshold   = 10         # CPU % threshold to trigger action
$gpuThreshold   = 5          # GPU % threshold to trigger action
$checkInterval  = 300        # Check interval in seconds (5 minutes)
$postCloseDelay = 180        # Delay before relaunching RNDR (3 minutes)

$appToClose  = "tcpsvcs.exe"
$appToLaunch = "C:\Path\to\your\RNDR\client\rndrclient.exe"

$nvidiaSmiPath = "nvidia-smi"  # Change to full path if needed

# === FUNCTION: Get Average CPU Usage ===
function Get-CpuUsage {
    return (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples[0].CookedValue
}

# === FUNCTION: Get GPU Usage (first GPU) ===
function Get-GpuUsage {
    try {
        $raw = & $nvidiaSmiPath --query-gpu=utilization.gpu --format=csv,noheader,nounits
        return [int]($raw -split "`n")[0].Trim()
    } catch {
        Write-Host "WARNING: Could not retrieve GPU usage. Assuming 100%."
        return 100
    }
}

# === MAIN LOOP ===
Write-Host "Monitoring CPU and GPU every $checkInterval seconds..."

while ($true) {
    $cpu = Get-CpuUsage
    $gpu = Get-GpuUsage
    $cpuRounded = [math]::Round($cpu, 2)

    Write-Host "CPU: $cpuRounded% | GPU: $gpu%"

    if ($cpu -lt $cpuThreshold -and $gpu -lt $gpuThreshold) {
        Write-Host "Both CPU and GPU below thresholds. Proceeding."

        # Check if process exists before trying to kill it
        if (Get-Process -Name ($appToClose -replace '\.exe$', '') -ErrorAction SilentlyContinue) {
            Write-Host "Closing $appToClose with taskkill..."
            taskkill /f /im $appToClose 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "WARNING: Could not close $appToClose"
            }
        } else {
            Write-Host "Process $appToClose not found"
        }

        Write-Host "Waiting $postCloseDelay seconds before starting $appToLaunch..."
        Start-Sleep -Seconds $postCloseDelay

        Write-Host "Launching $appToLaunch..."
        Start-Process $appToLaunch

        break
    } else {
        Write-Host "Conditions not met (CPU: $cpuRounded%, GPU: $gpu%). Waiting..."
    }

    Start-Sleep -Seconds $checkInterval
}