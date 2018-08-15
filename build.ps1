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
    $Action = "Test",
    [Parameter(Mandatory = $false)]
    [String]
    $OutputDirectory = "$PSScriptRoot/output",
    [Parameter(Mandatory = $false)]
    [ValidateSet(1, 2, 3)]
    [Int]
    $Stage = 1,
    [Parameter(Mandatory = $false)]
    [Switch]
    $NoUpdates
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

. $PSScriptRoot/floppy/utilities.ps1

if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

$isVerbose = [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
$isDebug = [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $DebugPreference

if ($isVerbose) {
    $parameters = [PSCustomObject] @{}
    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        $parameters | Add-Member -MemberType NoteProperty -Name $parameter.Key -Value $parameter.Value
    }

    ($parameters | Format-List | Out-String).Trim()
}

$data = Get-Content -Path "$PSScriptRoot/build.data.json" | ConvertFrom-Json
foreach ($datum in $data) {
    if ($datum.name -eq $Name) {
        $template = [PSCustomObject] @{
            Name               = $datum.Name
            OsName             = $datum.os_name
            SourceUrlEnvVar    = $datum.source_url_env_var
            SourceUrl          = $datum.source_url
            SourceChecksum     = $datum.source_checksum
            SourceChecksumType = $datum.source_checksum_type
        }

        break
    }
}

if (-not [String]::IsNullOrWhiteSpace($template.SourceUrlEnvVar) -and (Test-Path -Path env:$($template.SourceUrlEnvVar))) {
    $localIsoPath = (Get-Item -Path env:$($template.SourceUrlEnvVar)).Value
    if (-not [String]::IsNullOrWhiteSpace($localIsoPath) -and (Test-Path -Path $localIsoPath)) {
        $template.SourceUrl = $localIsoPath
    }
    else {
        Write-Verbose -Message "File not found, using default ISO URL"
    }
}
else {
    Write-Verbose -Message "Environment Variable not specified, using default ISO URL"
}

if ($isVerbose) {
    $template
}

if ($Provider -eq 'Hyper-V') {
    # TODO: Check OS for correct command to use
    if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online).State -ne "Enabled") {
        throw "You need to install and enable Hyper-V to run the Hyper-V Builder."
    }
}

if (-not (Test-Path -Path $OutputDirectory)) {
    Write-Output -InputObject '', "==> Creating output directory..."
    New-Item -Path $OutputDirectory -ItemType Directory
}

Remove-File -Path "$PSScriptRoot/logs/packer.log"
Write-Output -InputObject '', "==> Removing vendored cookbooks..."
Remove-Directory -Path "$PSScriptRoot/vendor/cookbooks"

$useChef = $Stage -eq 3
if ($useChef) {
    $cookbooks = @('provision')
    foreach ($cookbook in $cookbooks) {
        Write-Output -InputObject '', "==> Testing '$cookbook' cookbook..."
        $result = Invoke-Process -FilePath 'chef' -ArgumentList 'exec', 'rake', '--rakefile', "$PSScriptRoot/cookbooks/$cookbook/Rakefile"
        if ($result -ne 0) { exit $result }
    }

    foreach ($cookbook in $cookbooks) {
        Write-Output -InputObject '', "==> Acquiring dependencies for '$cookbook' cookbook..."
        $result = Invoke-Process -FilePath 'chef' -ArgumentList 'exec', 'berks', 'vendor', "$PSScriptRoot/vendor/cookbooks", "--berksfile=$PSScriptRoot/cookbooks/$cookbook/Berksfile", '--no-delete'
        if ($result -ne 0) { exit $result}
    }
}

$env:CHECKPOINT_DISABLE = 1
$env:PACKER_CACHE_DIR = "$env:ALLUSERSPROFILE/.packer.d/cache"
$env:PACKER_LOG = 1
$env:PACKER_LOG_PATH = "$PSScriptRoot/logs/packer.log"

$templateFilePath = "templates/$($Provider.ToLower().Replace('-', ''))/$Stage-windows.json"

Write-Output -InputObject '', "==> Validating template..."
$previousStage = $stage - 1
if ($Provider -eq "Hyper-V") {
    switch ($Stage) {
        1 {
            $sourceUrl = $template.SourceUrl
            $sourceChecksum = $template.SourceChecksum
            $sourceChecksumType = $template.SourceChecksumType
        }
        2 {
            $sourceUrl = "$OutputDirectory/$($template.OsName)-$previousStage-hyperv/Virtual Hard Disks/$($template.OsName)-$previousStage.vhdx"
            $sourceChecksum = ""
            $sourceChecksumType = "none"
        }
        3 {
            $sourceUrl = "$OutputDirectory/$($template.OsName)-$previousStage-hyperv/Virtual Hard Disks/$($template.OsName)-$previousStage.vhdx"
            $sourceChecksum = ""
            $sourceChecksumType = "none"
        }
    }
}

$variables = @(
    '--var', "`"os_name=$($template.OsName)`"",
    '--var', "`"source_checksum=$sourceChecksum`"",
    '--var', "`"source_checksum_type=$sourceChecksumType`"",
    '--var', "`"source_url=$sourceUrl`"",
    '--var', "`"output_dir=$OutputDirectory`""
)

if ($NoUpdates) {
    $variables += '--var', "`"no_updates=true`""
}

if ($isVerbose) {
    $variables += '--var', "`"verbose=true`""
}

$result = Invoke-Process -FilePath 'packer' -ArgumentList (@('validate', "--only=$($Action.ToLower())") + $variables + @($templateFilePath))
if ($result -ne 0) { exit $result }

Write-Output -InputObject '', "==> Inspecting template..."
$result = Invoke-Process -FilePath "packer" -ArgumentList 'inspect', $templateFilePath
if ($result -ne 0) { exit $result }

Remove-File -Path "$PSScriptRoot/logs/packer.log"

$arguments = @(
    'build',
    '--force',
    "--only=$($Action.ToLower())"
)

if ($isDebug) { $arguments += '--debug' }

Write-Output -InputObject '', "==> Building template..."
$result = Invoke-Process -FilePath "packer" -ArgumentList ($arguments + $variables + @($templateFilePath))
if ($result -ne 0) { exit $result }

Write-Output -InputObject '', "==> Displaying artifacts..."
Get-ChildItem -Path $OutputDirectory -Include * -Exclude .gitkeep | ForEach-Object {
    if ($_.PSIsContainer) {
        $type = "Directory"
        $size = (Get-ChildItem -Path $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum
    }
    else {
        $type = "File"
        $size = $_.Length
    }

    return [PSCustomObject] @{
        Type     = $type
        Size     = $size
        Artifact = "output/$($_.Name)"
    }
} | Format-Table -Property @(
    "Type",
    @{Name = "Size (MB)"; Expression = { "{0:N0}" -f ($_.Size / 1MB) }; Align = "Right"},
    "Artifact"
)

exit 0
