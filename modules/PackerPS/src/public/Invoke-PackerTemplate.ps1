function Invoke-PackerTemplate {
    [Alias("Invoke-PackerBuild")]
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([Int])]
    param (
        # Parameter help description
        [Parameter(Mandatory, ParameterSetName = "Default")]
        [Parameter(Mandatory, ParameterSetName = "Except")]
        [Parameter(Mandatory, ParameterSetName = "Only")]
        [String]
        $Path,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Parameter(Mandatory = $false, ParameterSetName = "Except")]
        [Parameter(Mandatory = $false, ParameterSetName = "Only")]
        [String[]]
        $Variables,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Parameter(Mandatory = $false, ParameterSetName = "Except")]
        [Parameter(Mandatory = $false, ParameterSetName = "Only")]
        [String[]]
        $VariableFiles,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Except")]
        [String[]]
        $Except,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Only")]
        [String[]]
        $Only,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [ValidateSet("Cleanup", "Abort", "Ask")]
        [String]
        $OnError = "Cleanup",
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Switch]
        $MachineReadable,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Switch]
        $NoColor,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Switch]
        $Force,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Switch]
        $DisableParallel
    )

    begin {
        $arguments = "build"
        $arguments += " --on-error=$($OnError.ToLower())"

        if ($MachineReadable) {
            $arguments += " --machine-readable"
        }

        if ([System.Management.Automation.ActionPreference]::SilentlyContinue -ne $DebugPreference) {
            $arguments += " --debug"
        }

        if ($Force) {
            $arguments += " --force"
        }

        if ($NoColor) {
            $arguments += " --color=false"
        }

        if ($DisableParallel) {
            $arguments += " --parallell=false"
        }

        if ($Except) {
            $arguments += " --except=$($Except -join ',')"
        }

        if ($Only) {
            $arguments += " --only=$($Only -join ',')"
        }

        if ($Variables) {
            $arguments += " --var `"$($Variables -join '" --var "')`""
        }

        if ($VariableFiles) {
            $arguments += " --var-file=$($VariableFiles -join ' --var-file=')"
        }
    }

    process {
        Write-Verbose -Message "Executing: packer $arguments `"$Path`""
        $process = Start-Process -FilePath "packer" -ArgumentList "$arguments `"$Path`"" -NoNewWindow -PassThru -Wait
        $process.WaitForExit()
        return $process.ExitCode
    }

    end {
    }
}
