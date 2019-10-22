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
