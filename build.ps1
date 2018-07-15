#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Windows2012R2")]
    [String]
    $Name = "Windows2012R2",
    [Parameter(Mandatory = $false)]
    [ValidateSet("Hyper-V")]
    [String]
    $Provider = "Hyper-V",
    [Parameter(Mandatory = $false)]
    [ValidateSet("Test")]
    [String]
    $Action = "Test"
)

$ErrorActionPreference = "Stop"

if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

$isVerbose = [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
$isDebug = [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $DebugPreference

$data = Get-Content -Path "$PSScriptRoot\build.data.json" | ConvertFrom-Json
foreach ($datum in $data) {
    if ($datum.name -eq $Name) {
        $template = [PSCustomObject] @{
            Name            = $datum.Name
            OsName          = $datum.os_name
            IsoUrlEnvVar    = $datum.iso_url_env_var
            IsoUrl          = $datum.iso_url
            IsoChecksum     = $datum.iso_checksum
            IsoChecksumType = $datum.iso_checksum_type
        }

        break
    }
}

if (-not [String]::IsNullOrWhiteSpace($template.IsoUrlEnvVar) -and (Test-Path -Path env:$($template.IsoUrlEnvVar))) {
    $localIsoPath = (Get-Item -Path env:$($template.IsoUrlEnvVar)).Value
    if (-not [String]::IsNullOrWhiteSpace($localIsoPath) -and (Test-Path -Path $localIsoPath)) {
        $template.IsoUrl = $localIsoPath
    }
    else {
        Write-Verbose -Message "File not found, using default ISO URL"
    }
}
else {
    Write-Verbose -Message "Environment Variable not specified, using default ISO URL"
}

$template

if (Test-Path -Path "$PSScriptRoot/logs/packer.log") {
    Remove-Item -Force -Recurse -Path "$PSScriptRoot/logs/packer.log"
}

$env:CHECKPOINT_DISABLE = 1
$env:PACKER_CACHE_DIR = "$env:ALLUSERSPROFILE\.packer.d\cache"
$env:PACKER_LOG = 1
$env:PACKER_LOG_PATH = "$PSScriptRoot/logs/packer.log"

$templateFilePath = 'templates/hyperv/windows.json'

Write-Output '', "==> Validating template..."
$variables = @(
    '--var', "`"os_name=$($template.OsName)`"",
    '--var', "`"iso_checksum=$($template.IsoChecksum)`"",
    '--var', "`"iso_checksum_type=$($template.IsoChecksumType)`"",
    '--var', "`"iso_url=$($template.IsoUrl)`""
)

$process = $null
$process = Start-Process -FilePath 'packer' -ArgumentList (@('validate', "--only=$($Action.ToLower())") + $variables + @($templateFilePath)) -NoNewWindow -Wait -PassThru
$process.WaitForExit()
if ($process.ExitCode -ne 0) { exit $process.ExitCode }

Write-Output '', "==> Inspecting template..."
$process = $null
$process = Start-Process -FilePath "packer" -ArgumentList 'inspect', $templateFilePath -NoNewWindow -Wait -PassThru
$process.WaitForExit()
if ($process.ExitCode -ne 0) { exit $process.ExitCode }

if (Test-Path -Path "$PSScriptRoot/logs/packer.log") {
    Remove-Item -Force -Path "$PSScriptRoot/logs/packer.log"
}

$arguments = @(
    'build',
    '--force',
    "--only=$($Action.ToLower())"
)

if ($isDebug) { $arguments += '--debug' }

Write-Output '', "==> Building template..."
Write-Output "Executing: 'packer $($arguments -join ' ') $($variables -join ' ') $templateFilePath'", ''

$process = $null
$process = Start-Process -FilePath "packer" -ArgumentList ($arguments + $variables + @($templateFilePath)) -NoNewWindow -Wait -PassThru
$process.WaitForExit()
exit $process.ExitCode
