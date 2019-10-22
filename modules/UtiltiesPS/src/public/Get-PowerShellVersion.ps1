function Get-PowerShellVersion {
    [CmdletBinding()]
    [OutputType([String])]
    param ()

    end {
        return $PSVersionTable.PSVersion.ToString()
    }
}
