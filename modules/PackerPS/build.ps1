[CmdletBinding()]
param (
)

begin {
    $ConfirmPreference = 'None'
    $ProgressPreference = 'SilentlyContinue'
    $ErrorActionPreference = 'Stop'

    if (-not [Boolean](Get-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue)) {
        Register-PSRepository -Default
    }
}

end {
    Invoke-psake $PSScriptRoot\build.psake.ps1 -taskList Test
    exit !$psake.build_success
}
