# PowerShell script to run Flutter integration test and save logs

# Define paths
$logFolder = "logs"
$logFile = "$logFolder/integration_test_scenario1.log"
$driverFile = "test_driver/integration_test.dart" # Correct driver file location
$targetFile = "test/integration_test/scenario1.dart" # Correct target test location
$recordedVideo = "testcase1.mp4" # Save as video5
$localVideoPath = "$logFolder/$recordedVideo"
$emulatorSerial = "emulator-5554"

# Ensure the logs directory exists
if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder
}

# Run Flutter integration test and specify the device
Write-Host "Running Flutter integration test..."
flutter drive --driver=$driverFile --target=$targetFile --device-id=$emulatorSerial *> $logFile 2>&1
# Check if the test ran successfully
if ($LASTEXITCODE -eq 0) {
    Write-Host "Integration test completed successfully. Logs saved to $logFile."
} else {
    Write-Host "Integration test failed. Check the logs at $logFile for details." -ForegroundColor Red
}