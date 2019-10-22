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
