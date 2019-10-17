function Get-SourceDirectory {
    [OutputType([System.IO.Path])]
    param(
        [Parameter()]
        [String]
        $TestDirectory
    )

    try {
        return [System.IO.Path]::GetFullPath((Join-Path -Path $TestDirectory -ChildPath '../src'))
    }
    catch {
        throw "An error occurred."
    }
}

function Get-ModuleManifest {
    param(
        [Parameter()]
        [String]
        $TestDirectory
    )

    return Get-Item -Path "$(Get-SourceDirectory -TestDirectory $TestDirectory)\*.psd1" -ErrorAction Stop
}

function Get-ModuleName {
    [OutputType([String])]
    param(
        [Parameter()]
        [String]
        $TestDirectory
    )

    try {
        return (Get-ModuleManifest -TestDirectory $TestDirectory -ErrorAction Stop).BaseName
    }
    catch {
        throw "An error occurred."
    }
}

function Get-TestFileName {
    [OutputType([String])]
    param(
        [Parameter()]
        [String]
        $Path
    )

    return (Split-Path -Leaf $Path -ErrorAction Stop).Replace('.Tests.', '.').Replace('.ps1', '')
}
