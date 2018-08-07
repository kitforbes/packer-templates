$ErrorActionPreference = 'Stop'
$ProgressPreference = "SilentlyContinue"
if ($Env:PACKER_VERBOSE) { $VerbosePreference = "Continue" }

. A:\utilities.ps1

Write-Output "==> Install-PackageProvider: NuGet"
Install-PackageProvider -Name NuGet -RequiredVersion "2.8.5.208" -Force -Confirm:$false

Write-Output "", "==> Install-Module: PowerShellGet"
Find-Module -Name PowerShellGet -RequiredVersion "1.6.0" |
    Install-Module -Force -AllowClobber

Write-Output "", "==> Install-Module: PSWindowsUpdate"
Find-Module -Name PSWindowsUpdate -RequiredVersion "2.0.0.4" |
    Install-Module -Force -AllowClobber

try {
    $module = Get-Module -Name PowerShellGet -ListAvailable | Where-Object -Property Version -eq "1.0.0.1"
    Remove-Module $module.Name -Force -Confirm:$false
    Remove-Item -Path $module.ModuleBase -Force -Recurse
}
catch {
    Write-Output "--> Could not fully remove PowerShellGet 1.0.0.1"
}

try {
    $module = Get-Module -Name PackageManagement -ListAvailable | Where-Object -Property Version -eq "1.0.0.1"
    Remove-Module $module.Name -Force -Confirm:$false
    Remove-Item -Path $module.ModuleBase -Force -Recurse
}
catch {
    Write-Output "--> Could not fully remove PackageManagement 1.0.0.1"
}

Write-Output "", "==> Get Modules"
Get-Module -ListAvailable -Verbose:$false | Select-Object Name, Version | Format-Table
exit 0
