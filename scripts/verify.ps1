$ErrorActionPreference = 'Stop'
$ProgressPreference = "SilentlyContinue"
if ($Env:PACKER_VERBOSE) { $VerbosePreference = "Continue" }

. A:\utilities.ps1

Write-Output -InputObject @(
    "==> Default Packer environment variables...",
    "PACKER_BUILD_NAME   : $(Get-PackerBuildName)",
    "PACKER_BUILDER_TYPE : $(Get-PackerBuildType)",
    "PACKER_HTTP_ADDR    : $(Get-PackerHttpAddress)"
)

Write-Output -InputObject "", "==> PowerShell Version information..."
$PSVersionTable.PSVersion

if (((Get-PowerShellVersion).Split(".")[0..1] -Join ".") -ne "5.1") {
    Write-Output -InputObject "Failing due to PowerShell 5.1 not being present, found v$(Get-PowerShellVersion)"
    exit 1
}

Write-Output -InputObject "", "==> Displaying logs..."
Get-ChildItem -Path "A:\*.log" | Get-Content

exit 0
