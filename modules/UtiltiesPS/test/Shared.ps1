#Requires -Modules Pester

$here = Split-Path -Parent -Path $MyInvocation.MyCommand.Path -ErrorAction Stop
# if (Test-Path -Path (Join-Path -Path $here -ChildPath 'helpers')) {
#     Get-ChildItem -Path (Join-Path -Path $here -ChildPath 'helpers') -Filter '*.ps1' -File |
#         Select-Object -ExpandProperty FullName |
#         ForEach-Object { . $_ }
# }

function Get-SourceDirectory {
    [OutputType([System.IO.Path])]
    param(
        [Parameter()]
        [String]
        $TestDirectory
    )

    try {
        # TODO: Use $PSScriptRoot
        return [System.IO.Path]::GetFullPath((Join-Path -Path $TestDirectory -ChildPath '../src'))
    }
    catch {
        throw "Boom!"
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
        throw "Boom!"
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

function BeforeFeature {
    Get-Module $module -ErrorAction SilentlyContinue | Remove-Module -Force -ErrorAction SilentlyContinue

    if (-not $SuppressImportModule) {
        Import-Module $moduleManifest.FullName -Scope Global
    }
}

function AfterFeature {
    Get-Module $module -ErrorAction SilentlyContinue | Remove-Module -Force -ErrorAction SilentlyContinue
}

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$moduleDir = Get-SourceDirectory -TestDirectory $here
$moduleManifest = Get-ModuleManifest -TestDirectory $here
$module = Get-ModuleName -TestDirectory $here
