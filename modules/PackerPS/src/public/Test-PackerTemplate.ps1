function Test-PackerTemplate {
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
        [Parameter(Mandatory = $false)]
        [Switch]
        $SyntaxOnly
    )

    begin {
        $arguments = "validate"
        if ($SyntaxOnly) {
            $arguments += " --syntax-only"
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
