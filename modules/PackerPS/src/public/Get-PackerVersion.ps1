function Get-PackerVersion {
    [CmdletBinding()]
    # [OutputType([Null])]
    param (
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [Switch]
        $Raw
    )

    begin {
    }

    process {
        Write-Verbose -Message "Executing: packer version"
        if ($Raw) {
            $process = Start-Process -FilePath "packer" -ArgumentList "version" -NoNewWindow -PassThru -Wait
            $process.WaitForExit()
            # return $process.ExitCode
            return $null
        }
        else {
            Measure-Command -Expression { packer version } | Select-Object -Property TotalSeconds
            Measure-Command -Expression { & packer version } | Select-Object -Property TotalSeconds
            Measure-Command -Expression { Invoke-Command -ScriptBlock { packer version } } | Select-Object -Property TotalSeconds
            Measure-Command -Expression { Start-Process -FilePath "packer" -ArgumentList "version" -NoNewWindow -PassThru -Wait } | Select-Object -Property TotalSeconds
        }
    }

    end {
    }
}
