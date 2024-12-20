# Step 1: Ensure the logs folder exists
if (!(Test-Path -Path "logs")) {
    New-Item -ItemType Directory -Path "logs"
}

# Step 2: Install the APK
Write-Output "Installing APK..."
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Step 3: Run integration tests using flutter drive
Write-Output "Running tests..."
flutter drive --target=test_driver/main.dart | Out-File -FilePath "logs/test_results.log" -Encoding utf8

# Step 4: Collect ADB logs
Write-Output "Collecting ADB logs..."
adb logcat -d | Out-File -FilePath "logs/adb_logs.log" -Encoding utf8

Write-Output "Test procedure completed. Logs saved in 'logs/' folder."
