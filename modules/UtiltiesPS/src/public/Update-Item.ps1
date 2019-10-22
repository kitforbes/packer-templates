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
            Write-Output -InputObject "'$Path' changed from '$currentValue' to '$Value'"
        }
        else {
            Write-Output -InputObject "'$Path' unchanged from '$currentValue'"
        }
    }
}
