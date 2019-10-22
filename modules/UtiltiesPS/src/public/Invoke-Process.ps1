function Invoke-Process {
    [CmdletBinding()]
    [OutputType([Int])]
    param (
        [Parameter(Mandatory)]
        [String]
        $FilePath,
        [Parameter(Mandatory)]
        [String[]]
        $ArgumentList,
        [Parameter(Mandatory = $false)]
        [Switch]
        $Quiet
    )

    end {
        Write-Verbose -Message "Executing: '$FilePath $($ArgumentList -join ' ')'"
        $startTime = Get-Date
        if ($Quiet) {
            Remove-File -Path "C:\Windows\Temp\invoke-process-out.txt"
            Remove-File -Path "C:\Windows\Temp\invoke-process-err.txt"
            $process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait -RedirectStandardOutput "C:\Windows\Temp\invoke-process-out.txt" -RedirectStandardError "C:\Windows\Temp\invoke-process-err.txt"
        }
        else {
            $process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait
        }

        $process.WaitForExit()
        $endTime = Get-Date
        $duration = ($endTime).Subtract($startTime)
        if ($duration.Minutes -le 0) {
            Write-Verbose -Message "Duration: $("{0:N3}" -f ($duration.TotalSeconds)) second(s)"
        }
        else {
            Write-Verbose -Message "Duration: $("{0:N0}" -f ($duration.TotalMinutes)) minute(s)"
        }

        return $process.ExitCode
    }
}
