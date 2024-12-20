# Debug: Print current directory
Write-Output "Current Directory: $(Get-Location)"

# Debug: Check if logs folder exists
if (!(Test-Path -Path "logs")) {
    Write-Output "Logs folder does not exist. Creating now..."
    New-Item -ItemType Directory -Path "logs"
} else {
    Write-Output "Logs folder already exists."
}

# Debug: Run controller tests and save logs
Write-Output "Running tests..."
flutter test test/controllers | Out-File -FilePath "logs/controllers_test.log" -Encoding utf8

# Debug: Check if log file was created
if (Test-Path -Path "logs/controllers_test.log") {
    Write-Output "Log file created successfully: logs/controllers_test.log"
} else {
    Write-Output "Failed to create log file."
}
