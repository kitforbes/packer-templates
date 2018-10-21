function Show-PackerTemplate {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([Int])]
    param (
        # Parameter help description
        [Parameter(Mandatory, ParameterSetName = "Default")]
        [String]
        $Path,
        # Parameter help description
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Switch]
        $MachineReadable
    )

    begin {
        $arguments = "inspect"
        if ($MachineReadable) {
            # Fails if "--machine-readable"
            $arguments += " -machine-readable"
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
