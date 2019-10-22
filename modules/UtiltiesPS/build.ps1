[CmdletBinding()]
param (
)

begin {
    $ConfirmPreference = 'None'
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Stop'
}

end {
    Invoke-psake $PSScriptRoot\build.psake.ps1 -taskList Test

    exit (!$psake.build_success)
}
