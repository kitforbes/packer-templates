#Requires -Modules Pester

$here = Split-Path -Parent -Path $MyInvocation.MyCommand.Path -ErrorAction Stop
if (Test-Path -Path (Join-Path -Path $here -ChildPath 'helpers')) {
    Get-ChildItem -Path (Join-Path -Path $here -ChildPath 'helpers') -Filter '*.ps1' -File |
        Select-Object -ExpandProperty FullName |
        ForEach-Object { . $_ }
}

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$moduleDir = Get-SourceDirectory -TestDirectory $here
$moduleManifest = Get-ModuleManifest -TestDirectory $here
$module = Get-ModuleName -TestDirectory $here

function BeforeFeature {
    Get-Module $module -ErrorAction SilentlyContinue | Remove-Module -Force -ErrorAction SilentlyContinue

    if (-not $SuppressImportModule) {
        Import-Module $moduleManifest.FullName -Scope Global
    }
}

function AfterFeature {
    Get-Module $module -ErrorAction SilentlyContinue | Remove-Module -Force -ErrorAction SilentlyContinue
}
