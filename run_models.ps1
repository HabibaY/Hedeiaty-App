# test_runner.ps1

# Configuration
$projectRoot = $PSScriptRoot
$testResultsPath = Join-Path $projectRoot "test_results"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $testResultsPath "test_run_$timestamp.log"
$jsonResultFile = Join-Path $testResultsPath "test_results_$timestamp.json"

# Create test results directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $testResultsPath | Out-Null

# Function to write to log file
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Tee-Object -FilePath $logFile -Append
}

Write-Log "Starting test execution..."

# Run flutter pub get to ensure dependencies
Write-Log "Installing dependencies..."
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Log "Failed to get dependencies. Exiting..."
    exit 1
}

# Run all tests with coverage
Write-Log "Running tests with coverage..."
flutter test --coverage --machine > "$testResultsPath\raw_test_output.json"

# Parse the machine output to create a more readable summary
$testResults = Get-Content "$testResultsPath\raw_test_output.json" | 
    ConvertFrom-Json |
    Where-Object { $_.type -eq "testDone" } |
    Select-Object -Property @{
        Name = "testName"; 
        Expression = { $_.testName }
    }, @{
        Name = "result"; 
        Expression = { $_.result }
    }

# Create summary
$summary = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    totalTests = $testResults.Count
    passed = ($testResults | Where-Object { $_.result -eq "success" }).Count
    failed = ($testResults | Where-Object { $_.result -eq "failure" }).Count
    skipped = ($testResults | Where-Object { $_.result -eq "skipped" }).Count
    results = $testResults
}

# Save summary to JSON
$summary | ConvertTo-Json -Depth 10 | Out-File $jsonResultFile

# Print summary to log
Write-Log "Test Execution Summary:"
Write-Log "Total Tests: $($summary.totalTests)"
Write-Log "Passed: $($summary.passed)"
Write-Log "Failed: $($summary.failed)"
Write-Log "Skipped: $($summary.skipped)"

Write-Log "Test execution completed. Results available in $testResultsPath"
