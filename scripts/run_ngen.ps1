$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
if ($Env:PACKER_VERBOSE) { $VerbosePreference = "Continue" }

. A:\utilities.ps1

Write-Output "", "Recompile DotNet cache..."
$result = Invoke-Process -FilePath "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe" -ArgumentList "update", "/force", "/queue", "/nologo", "/silent"
if ($result -ne 0) { exit $result }

Get-ScheduledTask -TaskName '.NET Framework NGEN v4.0.30319', '.NET Framework NGEN v4.0.30319 64' | Disable-ScheduledTask | Out-Null

$result = Invoke-Process -FilePath "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe" -ArgumentList "executeQueuedItems", "/nologo", "/silent" -Quiet
if ($result -ne 0) { exit $result }

Get-ScheduledTask -TaskName '.NET Framework NGEN v4.0.30319', '.NET Framework NGEN v4.0.30319 64' | Enable-ScheduledTask | Out-Null

exit 0
