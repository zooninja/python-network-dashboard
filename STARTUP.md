# Auto-Start Configuration for Windows

This guide shows how to configure the Python Network Dashboard to start automatically when you log into Windows with administrator privileges.

## Quick Setup

### Option 1: Batch File (Recommended)
1. **Right-click** `setup_startup.bat`
2. Select **"Run as administrator"**
3. Follow the on-screen prompts
4. Done! The dashboard will start automatically on next login

### Option 2: PowerShell Script
1. **Right-click** `setup_startup.ps1`
2. Select **"Run with PowerShell"** (as Administrator)
3. If prompted, allow the script to run
4. Follow the on-screen prompts

## What Gets Installed

A Windows Scheduled Task named `PythonNetworkDashboard` that:
- Runs at user login
- Executes with administrator privileges (required for network monitoring)
- Runs silently in the background (no visible window)
- Automatically restarts if it fails

## File Structure

```
network_dashboard/
├── start.bat              # Standard launcher (shows console)
├── start_admin.vbs        # Silent launcher with admin rights
├── setup_startup.bat      # Batch setup script (easy)
└── setup_startup.ps1      # PowerShell setup script (advanced)
```

## Managing the Auto-Start Task

### Check Task Status
Open Task Scheduler:
```cmd
taskschd.msc
```
Look for `PythonNetworkDashboard` in Task Scheduler Library

### Disable Auto-Start
```cmd
schtasks /change /tn "PythonNetworkDashboard" /disable
```

### Enable Auto-Start
```cmd
schtasks /change /tn "PythonNetworkDashboard" /enable
```

### Remove Auto-Start Completely
```cmd
schtasks /delete /tn "PythonNetworkDashboard" /f
```

Or run the setup script again - it will remove the old task first.

## Manual Startup

If you don't want auto-start, you can run the dashboard manually:

### With Admin Rights (Silent)
Double-click: `start_admin.vbs`
- Runs with admin privileges
- No visible console window
- You'll see a UAC prompt

### Standard (Console Visible)
Double-click: `start.bat`
- Shows console window with logs
- Useful for troubleshooting
- May need to run as admin manually

## Troubleshooting

### Dashboard Doesn't Start on Login
1. Open Task Scheduler (`taskschd.msc`)
2. Find `PythonNetworkDashboard` task
3. Right-click → Run to test it manually
4. Check the "Last Run Result" column
5. View the History tab for detailed logs

### UAC Prompts on Startup
This is normal - the dashboard needs admin rights to:
- Monitor network connections
- Access process information
- Terminate processes (if enabled)

You can't avoid the UAC prompt when using Scheduled Tasks with highest privileges for security reasons.

### Dashboard Running But Can't Access
Check if it's actually running:
```cmd
tasklist | findstr python
```

Try accessing: http://localhost:8081

Check Windows Firewall settings if blocked.

### Stop Running Dashboard
```cmd
taskkill /f /im python.exe
```

Or from Task Manager (Ctrl+Shift+Esc), find python.exe and end the task.

## Security Notes

- The dashboard runs with **administrator privileges** - only install on your personal machine
- Auto-start means it's always running when you're logged in
- Uses minimal resources when idle (~50-100MB RAM)
- Only listens on localhost by default (not exposed to network)

## Alternative: Windows Startup Folder

For a simpler approach without admin rights (but limited monitoring):

1. Press `Win+R`
2. Type: `shell:startup`
3. Create a shortcut to `start.bat`
4. Done!

**Limitations:**
- Won't have admin rights automatically
- Less process information visible
- Can't terminate elevated processes
- Will see UAC prompts if you manually elevate

## Uninstallation

To completely remove auto-start:

1. Remove the scheduled task:
   ```cmd
   schtasks /delete /tn "PythonNetworkDashboard" /f
   ```

2. Optionally delete the startup files:
   - `start_admin.vbs`
   - `setup_startup.bat`
   - `setup_startup.ps1`

The main application files (`server.py`, `start.bat`, etc.) are independent and can remain.
