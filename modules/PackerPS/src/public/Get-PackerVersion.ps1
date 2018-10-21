function Get-PackerVersion {
    [CmdletBinding()]
    [OutputType([Int])]
    param (
    )

    begin {
    }

    process {
        Write-Verbose -Message "Executing: packer version"
        $process = Start-Process -FilePath "packer" -ArgumentList "version" -NoNewWindow -PassThru -Wait
        $process.WaitForExit()
        return $process.ExitCode
    }

    end {
    }
}
