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
