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
            return (Get-CimInstance -ClassName Win32_OperatingSystem).Version
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

function Invoke-Process {
    [CmdletBinding()]
    [OutputType([Int])]
    param (
        [Parameter(Mandatory)]
        [String]
        $FilePath,
        [Parameter(Mandatory)]
        [String[]]
        $ArgumentList
    )

    end {
        Write-Verbose -Message "Executing: '$FilePath $($ArgumentList -join ' ')'"
        $process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait
        $process.WaitForExit()
        return $process.ExitCode
    }
}

function Test-Command {
    [CmdletBinding()]
    [OutputType([Int])]
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
