#Requires -RunAsAdministrator

[CmdletBinding(DefaultParameterSetName = "Default")]
param(
    [Parameter(Mandatory = $false, ParameterSetName = "Default")]
    [ValidateSet("Windows2012R2")]
    [String]
    $Name = "Windows2012R2",
    [Parameter(Mandatory = $false, ParameterSetName = "Default")]
    [ValidateSet("Hyper-V")]
    [String]
    $Provider = "Hyper-V",
    [Parameter(Mandatory = $false, ParameterSetName = "Default")]
    [ValidateSet("Test")]
    [String]
    $Action = "Test",
    [Parameter(Mandatory = $false, ParameterSetName = "Default")]
    [Parameter(Mandatory = $false, ParameterSetName = "Clean")]
    [String]
    $OutputDirectory = "$PSScriptRoot/output",
    [Parameter(Mandatory = $false, ParameterSetName = "Default")]
    [String]
    $LogDirectory = "$PSScriptRoot/logs",
    [Parameter(Mandatory = $false, ParameterSetName = "Default")]
    [ValidateSet(1, 2, 3)]
    [Int]
    $Stage = 1,
    [Parameter(Mandatory = $false, ParameterSetName = "Default")]
    [Switch]
    $NoUpdates,
    [Parameter(Mandatory = $false, ParameterSetName = "Clean")]
    [Switch]
    $ClearOutput
)

begin {
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"

    . "$PSScriptRoot/floppy/utilities.ps1"

    if (-not $PSScriptRoot) {
        $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
    }

    # Import in-development PackerPS module
    Remove-Module -Name "PackerPS" -Force -ErrorAction SilentlyContinue
    Import-Module -Name "$PSScriptRoot\modules\PackerPS\src\PackerPS.psd1" -Force

    $isVerbose = [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
    $isDebug = [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $DebugPreference

    function Measure-OutputContent {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [String]
            $Path
        )

        end {
            Write-Output -InputObject '', "==> Displaying artifacts..."
            Get-ChildItem -Path $Path -Include * -Exclude .gitkeep | ForEach-Object {
                if ($_.PSIsContainer) {
                    $type = "Directory"
                    $size = Get-ChildItem -Path $_.FullName -Recurse |
                        Measure-Object -Property Length -Sum |
                        Select-Object -ExpandProperty Sum
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
        }
    }
}

end {
    # Remove any trailing backslashes from output directory.
    if ($OutputDirectory -match "\\$") {
        $OutputDirectory = $OutputDirectory.TrimEnd('\')
    }

    # Remove any trailing backslashes from log directory.
    if ($LogDirectory -match "\\$") {
        $LogDirectory = $LogDirectory.TrimEnd('\')
    }

    if ($isVerbose) {
        $parameters = [PSCustomObject] @{}
        foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
            $parameters | Add-Member -MemberType NoteProperty -Name $parameter.Key -Value $parameter.Value
        }

        ($parameters | Format-List | Out-String).Trim()
    }

    if ($PSCmdlet.ParameterSetName -eq "Clean") {
        # Remove all files from output directory.
        Get-ChildItem -Path $OutputDirectory -Include * -Exclude .gitkeep | ForEach-Object {
            if ($_.PSIsContainer) {
                Remove-Item -Path $_ -Force -Recurse -Verbose:$isVerbose
            }
            else {
                Remove-Item -Path $_ -Force -Verbose:$isVerbose
            }
        }

        Write-Output -InputObject '', "==> Ouput directory wiped."
        exit 0
    }

    # Get values from data file.
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

    # Use local ISO if present.
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

    # Verify provider prerequisites.
    if ($Provider -eq 'Hyper-V') {
        # TODO: Check OS for correct command to use
        if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online).State -ne "Enabled") {
            throw "Hyper-V needs to be enabled to use the Hyper-V provider."
        }
    }

    # Ensure output and logs directory exist.
    New-Directory -Path $OutputDirectory
    New-Directory -Path $LogDirectory

    # Delete Packer log file if present.
    Remove-File -Path "$LogDirectory/packer.log"

    # Delete vendored cookbooks.
    Write-Output -InputObject '', "==> Removing vendored cookbooks..."
    Remove-Directory -Path "$PSScriptRoot/vendor/cookbooks"

    # Only verify cookbooks if required for the build.
    $useChef = $Stage -eq 3
    if ($useChef) {
        # Get all cookbooks within the cookbooks directory.
        $cookbooks = Get-ChildItem -Path "$PSScriptRoot/cookbooks" |
            Where-Object -FilterScript { $_.PSIsContainer } |
            Select-Object -ExpandProperty Name

        foreach ($cookbook in $cookbooks) {
            # Execute cookbook tests.
            Write-Output -InputObject '', "==> Testing '$cookbook' cookbook..."
            $result = Invoke-Process -FilePath 'chef' -ArgumentList 'exec', 'rake', '--rakefile', "$PSScriptRoot/cookbooks/$cookbook/Rakefile"
            if ($result -ne 0) { exit $result }
        }

        foreach ($cookbook in $cookbooks) {
            # Acquire cookbook dependencies.
            Write-Output -InputObject '', "==> Acquiring dependencies for '$cookbook' cookbook..."
            $result = Invoke-Process -FilePath 'chef' -ArgumentList 'exec', 'berks', 'vendor', "$PSScriptRoot/vendor/cookbooks", "--berksfile=$PSScriptRoot/cookbooks/$cookbook/Berksfile", '--no-delete'
            if ($result -ne 0) { exit $result}
        }
    }

    # Set Packer environment variables.
    $env:CHECKPOINT_DISABLE = 1
    $env:PACKER_CACHE_DIR = "$env:ALLUSERSPROFILE/.packer.d/cache"
    $env:PACKER_LOG = 1
    $env:PACKER_LOG_PATH = "$LogDirectory/packer.log"

    # Determine path to Packer template file.
    $templateFilePath = "templates/$($Provider.ToLower().Replace('-', ''))/$Stage-windows.json"

    # Prepare sources based on standard locations.
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

    # Prepare variables for Packer.
    $variables = @(
        "os_name=$($template.OsName)",
        "source_checksum=$sourceChecksum",
        "source_checksum_type=$sourceChecksumType",
        "source_url=$sourceUrl",
        "output_dir=$OutputDirectory",
        "stage=$Stage"
    )

    if ($NoUpdates) {
        $variables += "no_updates=true"
    }

    if ($isVerbose) {
        $variables += "verbose=true"
    }

    # Validate Packer template.
    Write-Output -InputObject '', "==> Validating template..."
    $result = Test-PackerTemplate -Path $templateFilePath -Only $Action -Variables $variables -Verbose:$isVerbose
    if ($result -ne 0) { exit $result }

    # Inspect Packer template.
    Write-Output -InputObject '', "==> Inspecting template..."
    $result = Show-PackerTemplate -Path $templateFilePath -Verbose:$isVerbose
    if ($result -ne 0) { exit $result }

    # Delete Packer log file before executing the build.
    Remove-File -Path "$LogDirectory/packer.log"

    # Build Packer template.
    Write-Output -InputObject '', "==> Building template..."
    $result = Invoke-PackerTemplate -Path $templateFilePath -Only $Action -Variables $variables -Force -Verbose:$isVerbose -Debug:$isDebug
    if ($result -ne 0) { exit $result }

    # Get size of artefacts within output directory.
    Measure-OutputContent -Path $OutputDirectory
    exit 0
}
