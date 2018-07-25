$ErrorActionPreference = 'Stop'

Write-Output "PowerShell Version information..."
$PSVersionTable.PSVersion

Write-Output "", "Default Packer environment variables..."
Write-Output "PACKER_BUILD_NAME   : $env:PACKER_BUILD_NAME"
Write-Output "PACKER_BUILDER_TYPE : $env:PACKER_BUILDER_TYPE"
Write-Output "PACKER_HTTP_ADDR    : $env:PACKER_HTTP_ADDR"

$powerShellVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
if ($powerShellVersion -ne "5.1") {
    Write-Output "Failing due to PowerShell 5.1 not being present, found v$powerShellVersion"
    exit 1
}
