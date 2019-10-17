#Requires -Modules Pester
. $PSScriptRoot\..\Shared.ps1
$function = Get-TestFileName -Path $MyInvocation.MyCommand.Path

BeforeFeature

Describe $function -Tags ('unit') {
    Context 'When tests execute' {
        It "Passes" {
            $true | Should be $true
        }
    }
}

AfterFeature
