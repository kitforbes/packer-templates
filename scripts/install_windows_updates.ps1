$ErrorActionPreference = 'Stop'
$ProgressPreference = "SilentlyContinue"
if ($Env:PACKER_VERBOSE) { $VerbosePreference = "Continue" }

if ($Env:PACKER_NO_UPDATES) {
    Write-Output -InputObject "Skipping installation of Windows updates."
}
else {
    Get-WindowsUpdate -WindowsUpdate -AcceptAll -Install -IgnoreReboot
}

exit 0
