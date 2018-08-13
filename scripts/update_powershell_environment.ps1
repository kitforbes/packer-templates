$ErrorActionPreference = 'Stop'
$ProgressPreference = "SilentlyContinue"
if ($Env:PACKER_VERBOSE) { $VerbosePreference = "Continue" }

Write-Output -InputObject "==> PowerShell Version..."
$PSVersionTable.PSVersion
if (($PSVersionTable.PSVersion.ToString().Split('.')[0..1] -Join '.') -ne '5.1') {
    exit 1
}

Write-Output -InputObject "", "==> Install-PackageProvider: NuGet"
Install-PackageProvider -Name NuGet -RequiredVersion "2.8.5.208" -Force -Confirm:$false

Write-Output -InputObject "", "==> Install-Module: PowerShellGet"
Find-Module -Name PowerShellGet -RequiredVersion "1.6.0" |
    Install-Module -Force -AllowClobber

Write-Output -InputObject "", "==> Install-Module: PSWindowsUpdate"
Find-Module -Name PSWindowsUpdate -RequiredVersion "2.0.0.4" |
    Install-Module -Force -AllowClobber

exit 0
