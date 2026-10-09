$DeviceMatch = "*VID_0781&PID_5567*"

# 1. Verify USB is connected on launch
$device = Get-PnpDevice -Class USB | Where-Object { $_.InstanceId -like $DeviceMatch -and $_.Status -eq "OK" }
if (-not $device) { exit }

# 2. Confirmation chirp on plug-in (2 beeps)
[console]::beep(1000, 300)
Start-Sleep -Milliseconds 150
[console]::beep(1000, 300)

# Helper function to check if device is still connected
function Test-UsbPlugged {
    $check = Get-PnpDevice -Class USB | Where-Object { $_.InstanceId -like $DeviceMatch -and $_.Status -eq "OK" }
    if (-not $check) { exit }
}

# 3. Main 20-20-20 Loop
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

    # Phase B: Wait 20 seconds
    $breakTimer = [System.Diagnostics.Stopwatch]::StartNew()
    while ($breakTimer.Elapsed.TotalSeconds -lt 20) {
        Start-Sleep -Seconds 2
        Test-UsbPlugged
    }
    $breakTimer.Stop()

    # Alert 2: Break finished, resume work (3 beeps)
    [console]::beep(1200, 300)
    Start-Sleep -Milliseconds 150
    [console]::beep(1200, 300)
    Start-Sleep -Milliseconds 150
    [console]::beep(1200, 300)
}