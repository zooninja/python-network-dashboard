# Python Network Dashboard - Startup Task Setup Script
# This script creates a scheduled task to run the dashboard at login with admin rights
#
# Run this script as Administrator:
# Right-click -> Run with PowerShell (as Admin)

# Ensure running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script must be run as Administrator!"
    Write-Host "Right-click the script and select 'Run with PowerShell' as Administrator."
    pause
    exit
}

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VBScriptPath = Join-Path $ScriptDir "start_admin.vbs"

# Check if VBS script exists
if (-not (Test-Path $VBScriptPath)) {
    Write-Error "Error: start_admin.vbs not found in $ScriptDir"
    pause
    exit
}

# Task configuration
$TaskName = "PythonNetworkDashboard"
$TaskDescription = "Automatically starts Python Network Dashboard with admin rights at login"
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

Write-Host "============================================================"
Write-Host "Python Network Dashboard - Startup Task Setup"
Write-Host "============================================================"
Write-Host ""
Write-Host "This will create a scheduled task that:"
Write-Host "  - Runs at login for user: $CurrentUser"
Write-Host "  - Starts the dashboard with administrator privileges"
Write-Host "  - Runs silently in the background"
Write-Host ""
Write-Host "VBS Script location: $VBScriptPath"
Write-Host ""

# Remove existing task if it exists
$ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($ExistingTask) {
    Write-Host "Removing existing task..."
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Create new task action
$Action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$VBScriptPath`"" -WorkingDirectory $ScriptDir

# Create trigger (at logon)
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $CurrentUser

# Create task settings
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

# Create task principal (run with highest privileges)
$Principal = New-ScheduledTaskPrincipal -UserId $CurrentUser -LogonType Interactive -RunLevel Highest

# Register the task
Write-Host "Creating scheduled task..."
Register-ScheduledTask `
    -TaskName $TaskName `
    -Description $TaskDescription `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -Principal $Principal `
    -Force | Out-Null

Write-Host ""
Write-Host "SUCCESS! Scheduled task created successfully."
Write-Host ""
Write-Host "============================================================"
Write-Host "Configuration Summary:"
Write-Host "============================================================"
Write-Host "Task Name:     $TaskName"
Write-Host "Trigger:       At user login ($CurrentUser)"
Write-Host "Run Level:     Highest (Administrator)"
Write-Host "Status:        Enabled"
Write-Host ""
Write-Host "The dashboard will now start automatically when you log in."
Write-Host ""
Write-Host "To manage the task:"
Write-Host "  - Open Task Scheduler (taskschd.msc)"
Write-Host "  - Look for '$TaskName' in Task Scheduler Library"
Write-Host ""
Write-Host "To disable auto-start:"
Write-Host "  Run: Disable-ScheduledTask -TaskName '$TaskName'"
Write-Host ""
Write-Host "To remove auto-start:"
Write-Host "  Run: Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false"
Write-Host ""
Write-Host "============================================================"
Write-Host ""
Write-Host "Press any key to exit..."
pause
