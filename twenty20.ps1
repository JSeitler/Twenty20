$DeviceMatch = "*VID_XXXX&PID_YYYY*"

# 1. Verify USB is connected on launch
$device = Get-PnpDevice -Class USB | Where-Object { $_.InstanceId -like $DeviceMatch -and $_.Status -eq "OK" }
if (-not $device) { exit }

# Helper functions for brightness control
function Get-ScreenBrightness {
    try {
        return (Get-CimInstance -Namespace root/wmi -ClassName WmiMonitorBrightness).CurrentBrightness
    } catch {
        return $null
    }
}

function Set-ScreenBrightness ([int]$level) {
    try {
        Get-CimInstance -Namespace root/wmi -ClassName WmiMonitorBrightnessMethods | 
            Invoke-CimMethod -MethodName WmiSetBrightness -Arguments @{ Timeout = 1; Brightness = $level } | Out-Null
    } catch {}
}

# Cache initial brightness
$script:savedBrightness = Get-ScreenBrightness

# Helper function to check if device is still connected
function Test-UsbPlugged {
    $check = Get-PnpDevice -Class USB | Where-Object { $_.InstanceId -like $DeviceMatch -and $_.Status -eq "OK" }
    if (-not $check) { 
        # Restore brightness before exiting if unplugged
        if ($null -ne $script:savedBrightness) { Set-ScreenBrightness $script:savedBrightness }
        exit 
    }
}

# 2. Confirmation chirp on plug-in (2 beeps)
[console]::beep(1000, 300)
Start-Sleep -Milliseconds 150
[console]::beep(1000, 300)

# 3. Main 20-20-20 Loop
try {
    while ($true) {
        # Phase A: Wait 20 minutes (1200 seconds)
        $timer = [System.Diagnostics.Stopwatch]::StartNew()
        while ($timer.Elapsed.TotalSeconds -lt 1200) {
            Start-Sleep -Seconds 10
            Test-UsbPlugged
        }
        $timer.Stop()

        # Alert 1: Start 20-second break (2 beeps)
        [console]::beep(1000, 400)
        Start-Sleep -Milliseconds 200
        [console]::beep(1000, 400)

        # Record current brightness right before dimming
        $current = Get-ScreenBrightness
        if ($null -ne $current) { $script:savedBrightness = $current }

        # Dim screen to 0%
        Set-ScreenBrightness 0

        # Phase B: Wait 20 seconds
        $breakTimer = [System.Diagnostics.Stopwatch]::StartNew()
        while ($breakTimer.Elapsed.TotalSeconds -lt 20) {
            Start-Sleep -Seconds 2
            Test-UsbPlugged
        }
        $breakTimer.Stop()

        # Restore original brightness
        if ($null -ne $script:savedBrightness) {
            Set-ScreenBrightness $script:savedBrightness
        }

        # Alert 2: Break finished, resume work (3 beeps)
        [console]::beep(1200, 300)
        Start-Sleep -Milliseconds 150
        [console]::beep(1200, 300)
        Start-Sleep -Milliseconds 150
        [console]::beep(1200, 300)
    }
}
finally {
    # Failsafe: always restore brightness if script stops unexpectedly
    if ($null -ne $script:savedBrightness) {
        Set-ScreenBrightness $script:savedBrightness
    }
}