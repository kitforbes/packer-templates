function Repair-PackerTemplate {
    [Alias("Invoke-PackerFix")]
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        # Parameter help description
        [Parameter(Mandatory, ParameterSetName = "Default")]
        [String]
        $Path,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Switch]
        $Validate
    )

    begin {
        $arguments = "fix"
        if ($Validate) {
            $arguments += "--validate=true"
        }
        else {
            $arguments += "--validate=false"
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
