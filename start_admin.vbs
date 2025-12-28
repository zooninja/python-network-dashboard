' Python Network Dashboard - Silent Admin Launcher
' This script launches the dashboard with administrator privileges
' without showing a command prompt window

Set objShell = CreateObject("Shell.Application")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Path to the batch file
strBatchFile = strScriptPath & "\start.bat"

' Check if batch file exists
If objFSO.FileExists(strBatchFile) Then
    ' Run the batch file with admin rights, hidden window
    ' Use "runas" verb to request elevation
    ' Parameters: file, parameters, working directory, verb, window style
    ' Window style 0 = hidden
    objShell.ShellExecute "cmd.exe", "/c """ & strBatchFile & """", strScriptPath, "runas", 0
Else
    MsgBox "Error: start.bat not found in " & strScriptPath, vbCritical, "Dashboard Launcher Error"
End If
