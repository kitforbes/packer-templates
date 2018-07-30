$ErrorActionPreference = 'Stop'
$ProgressPreference = "SilentlyContinue"

. A:\utilities.ps1

Write-Output "==> Default Packer environment variables..."
Write-Output "PACKER_BUILD_NAME   : $(Get-PackerBuildName)"
Write-Output "PACKER_BUILDER_TYPE : $(Get-PackerBuildType)"
Write-Output "PACKER_HTTP_ADDR    : $(Get-PackerHttpAddress)"

Write-Output "", "==> PowerShell Version information..."
$PSVersionTable.PSVersion

if (((Get-PowerShellVersion).Split(".")[0..1] -Join ".") -ne "5.1") {
    Write-Output "Failing due to PowerShell 5.1 not being present, found v$(Get-PowerShellVersion)"
    exit 1
}

Write-Output "", "==> Displaying logs..."
Get-ChildItem -Path "A:\*.log" | Get-Content

exit 0
