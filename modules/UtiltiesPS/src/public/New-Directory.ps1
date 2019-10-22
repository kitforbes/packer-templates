function New-Directory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Path
    )

    end {
        if (-not (Test-Path -Path $Path)) {
            New-Item -Path $Path -ItemType Directory
        }
    }
}
