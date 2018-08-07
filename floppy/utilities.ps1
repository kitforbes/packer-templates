function Get-PackerBuildName {
    [CmdletBinding()]
    [OutputType([String])]
    param ()

    end {
        return $env:PACKER_BUILD_NAME
    }
}

function Get-PackerBuildType {
    [CmdletBinding()]
    [OutputType([String])]
    param ()

    end {
        return $env:PACKER_BUILDER_TYPE
    }
}

function Get-PackerHttpAddress {
    [CmdletBinding()]
    [OutputType([String])]
    param ()

    end {
        return $env:PACKER_HTTP_ADDR
    }
}

function Get-OperatingSystemVersion {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $false)]
        [Switch]
        $DisplayName
    )

    end {
        if ($DisplayName) {
            $lookupTable = @{
                "5.1.2600" = "Windows XP";
                "5.1.3790" = "Windows Server 2003";
                "6.0.6001" = "Windows Vista/Windows Server 2008";
                "6.1.7600" = "Windows 7/Windows Server 2008 R2";
                "6.1.7601" = "Windows 7 SP1/Windows Server 2008 R2 SP1";
                "6.2.9200" = "Windows 8/Windows Server 2012";
                "6.3.9600" = "Windows Server 8.1/Windows Server 2012 R2";
                "10.0.*"   = "Windows 10/Windows Server 2016"
            }

            $version = (Get-CimInstance -ClassName Win32_OperatingSystem).Version

            if ($version.Split(".")[0] -eq "10") {
                return $lookupTable["10.0.*"]
            }

            return $lookupTable[$version]
        }
        else {
            if (Test-Command -Name Get-CimInstance) {
                return (Get-CimInstance -ClassName Win32_OperatingSystem).Version
            }
            else {
                throw
            }
        }
    }
}

function Get-PowerShellVersion {
    [CmdletBinding()]
    [OutputType([String])]
    param ()

    end {
        return $PSVersionTable.PSVersion.ToString()
    }
}

function Get-Verbose {
    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    end {
        return [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
    }
}

function Remove-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Path
    )

    end {
        if (Test-Path -Path $Path) {
            Remove-Item -Force -Path $Path
        }
    }
}

function Remove-Directory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Path
    )

    end {
        if (Test-Path -Path $Path) {
            Remove-Item -Force -Path $Path -Recurse
        }
    }
}

function Update-Item {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Path,
        [Parameter(Mandatory)]
        [String]
        $Value
    )

    end {
        $currentValue = (Get-Item -Path $Path).Value
        if ($currentValue -ne $Value) {
            Set-Item -Path $Path -Value $Value
            Write-Output "'$Path' changed from '$currentValue' to '$Value'"
        }
        else {
            Write-Output "'$Path' unchanged from '$currentValue'"
        }
    }
}

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

function Test-Command {
    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory)]
        [String]
        $Name
    )

    end {
        try {
            Get-Command -Name $Name
            return $true
        }
        catch {
            $global:Error.RemoveAt(0)
            return $false
        }
    }
}
