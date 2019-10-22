if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$helperFunctions = @()
if (Test-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'helpers')) {
    Write-Verbose -Message "Sourcing helper functions..."
    $helperFunctions = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'helpers') -Filter '*.ps1' -File -ErrorAction Stop)
}

$privateFunctions = @()
if (Test-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'private')) {
    Write-Verbose -Message "Sourcing private functions..."
    $privateFunctions = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'private') -Filter '*.ps1' -File -ErrorAction Stop)
}

$publicFunctions = @()
if (Test-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'public')) {
    Write-Verbose -Message "Sourcing public functions..."
    $publicFunctions = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'public') -Filter '*.ps1' -File -ErrorAction Stop)
}

foreach ($function in @($helperFunctions + $privateFunctions + $publicFunctions)) {
    try {
        Write-Verbose -Message "Importing $($function.FullName)..."
        . $function.FullName
    }
    catch {
        throw "Unable to dot source '$($function.FullName)'"
    }
}

foreach ($function in $publicFunctions) {
    Export-ModuleMember -Function $function.BaseName
}
