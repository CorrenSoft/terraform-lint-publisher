
param(
  [string]$MinimumSeverity,
  [string]$Recursive,
  [string]$ReportCheckRun,
  [string]$ReportPullRequest,
  [string]$ReportSummary,
  [string]$WorkingDirectory
)

$reportDir = Join-Path $PWD 'tflint-reports'
$report = Join-Path $reportDir 'report.xml'
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

try {
  tflint --init
  $rec = if ($Recursive -eq 'true') { '--recursive' } else { '' }

  tflint --chdir "$WorkingDirectory" $rec -f junit --minimum-failure-severity $MinimumSeverity > $report

  [xml]$xml = Get-Content $report
  $suite = $xml.testsuites.testsuite
  $total = [int]$suite.tests
  $errors = [int]$suite.failures
  $warnings = [int]$suite.warnins
  $state = if ($errors -gt 0) { 'failure' } else { 'success' }
}
catch {
  # If tflint crash, close early.
  $failureMessage = "TFLint has failed on execution: $_"
  "failureMessage=$failureMessage" >> $env:GITHUB_OUTPUT
  return
}

$somethingToReport = ($errors -gt 0) -or ($warnings -gt 0)

# Build messages
$message = "### Terraform Lint Summary
`n**Errors:** $errors  **Warnings:** $warnings`
"
if ($somethingToReport) {
  $message += "<details><summary>Details</summary>

Errors: $errors
Warnings: $warnings
</details>"
} 

switch ($ReportCheckRun) {
  'always' { 
    if ($somethingToReport) {
      $checkMessage = "$errors error(s), $warnings warning(s)" 
    }
    else {
      $checkMessage = "No issues found."
    }
  }
  'on-findings' {
    $checkMessage = "$errors error(s), $warnings warning(s)" 
  }
  Default {
    $checkMessage = ""
  }
}

switch ($ReportPullRequest) {
  'always' { 
    $prMessage = $message
  }
  'on-findings' {
    $prMessage = $summarymessageessage
  }
  Default {
    $prMessage = ""
  }
}

switch ($ReportPullRequest) {
  'always' { 
    $summaryMessage = $message
  }
  'on-findings' {
    $summaryMessage = $message
  }
  Default {
    $summaryMessage = ""
  }
}

# outputs
"state=$state" >> $env:GITHUB_OUTPUT
"total=$total" >> $env:GITHUB_OUTPUT
"errors=$errors" >> $env:GITHUB_OUTPUT
"warnings=$warnings" >> $env:GITHUB_OUTPUT
"report_path=$report" >> $env:GITHUB_OUTPUT
"summary_message<<EOF`n$summaryMessage`nEOF" >> $env:GITHUB_OUTPUT
"pr_message<<EOF`n$prMessage`nEOF" >> $env:GITHUB_OUTPUT
"check_message=$checkMessage" >> $env:GITHUB_OUTPUT
