
param(
    # Can include this switch when running from the .wsb file to indicate it's the first launch of the sandbox
    # Useful if re-running this script within the sandbox as a test, but don't want certain parts to run again
    [switch]$launchingSandbox
)

#Set-PSDebug -Trace 1

# Show file extensions
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f

# Show hidden files
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 1 /f

# Fix for slow MSI package install. See: https://github.com/microsoft/Windows-Sandbox/issues/68#issuecomment-2754867968
reg add HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy /v VerifiedAndReputablePolicyState /t REG_DWORD /d 0 /f
CiTool.exe --refresh --json | Out-Null # Refreshes policy. Use json output param or else it will prompt for confirmation, even with Out-Null

# Change execution policy for powershell to allow running scripts. Normally it shows an error about a more specific policy (Process level Bypass policy), but it doesn't matter so we hide it via try/catch
try { Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -ErrorAction Stop | Out-Null } catch {}

# -----------------------------------------------------------------------------------------

# ---- Add 'Open PowerShell Here' and 'Open CMD Here' to context menu -------
$powershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$cmdPath = "C:\Windows\System32\cmd.exe"
Write-Host "`nAdding 'Open PowerShell/CMD Here' context menu options"
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\MyPowerShell" /ve /d "Open PowerShell Here" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\MyPowerShell" /v "Icon" /t REG_SZ /d "$powershellPath,0" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\MyPowerShell\command" /ve /d "powershell.exe -noexit -command Set-Location -literalPath '%V'" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Mycmd" /ve /d "Open CMD Here" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Mycmd" /v "Icon" /t REG_SZ /d "$cmdPath,0" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Mycmd\command" /ve /d "cmd.exe /s /k cd /d `"\`"%V`"\`"" /f

# ---- Add File Types to Context Menu > New ----
# ShellNew Text Document - .txt
Write-host "`nAdding txt document new file option"
reg add "HKEY_CLASSES_ROOT\txtfile" /ve /d "Text Document" /f
reg add "HKEY_CLASSES_ROOT\.txt\ShellNew" /f
# Use --% to not have powershell parse the arguments, otherwise it won't pass the empty string for the /d parameter
reg --% add "HKEY_CLASSES_ROOT\.txt\ShellNew" /v "NullFile" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\.txt\ShellNew" /v "ItemName" /t REG_SZ /d "New Text Document" /f

# ShellNew PowerShell Script - .ps1 -- Also happens to make .ps1 scripts clickable to run because of the association with "ps1file"
Write-host "`nAdding PowerShell new file option"
reg add "HKEY_CLASSES_ROOT\.ps1" /ve /d "ps1file" /f
reg add "HKEY_CLASSES_ROOT\ps1file" /ve /d "PowerShell Script" /f
reg add "HKEY_CLASSES_ROOT\ps1file\DefaultIcon" /ve /d "%SystemRoot%\System32\imageres.dll,-5372" /f
reg add "HKEY_CLASSES_ROOT\.ps1\ShellNew" /ve /d "ps1file" /f
reg add "HKEY_CLASSES_ROOT\.ps1\ShellNew" /f
reg --% add "HKEY_CLASSES_ROOT\.ps1\ShellNew" /v "NullFile" /t REG_SZ /d "" /f
reg add "HKEY_CLASSES_ROOT\.ps1\ShellNew" /v "ItemName" /t REG_SZ /d "script" /f

# ================================ FINALIZATION ================================

# Restart Explorer so changes take effect
Stop-Process -Name explorer -Force

# Open an explorer window to the host-shared folder on first launch
if ($launchingSandbox) { Start-Process explorer.exe C:\Users\WDAGUtilityAccount\Desktop\HostShared }

# Uncomment to pause after running
#Read-Host "Pause"

