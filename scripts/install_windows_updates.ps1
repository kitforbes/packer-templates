$ErrorActionPreference = 'Stop'
$ProgressPreference = "SilentlyContinue"

if ($Env:PACKER_NO_UPDATES) {
    Write-Output "Skipping installation of Windows updates."
    exit 0
}

Get-WindowsUpdate -WindowsUpdate -AcceptAll -Install -IgnoreReboot
exit 0
