#Requires -Modules Pester
. $PSScriptRoot\..\Shared.ps1
$function = Get-TestFileName -Path $MyInvocation.MyCommand.Path

BeforeFeature

Describe $function -Tags ('unit') {
    InModuleScope $module {
        Context 'Grant node access to creds_ou_remediation Chef Vault' {
            It 'Calls Update-ChefVaultForNodeName to set access to creds_ou_remediation Chef Vault' {
                Mock -CommandName Update-ChefVaultForNodeName -MockWith {} -ParameterFilter {
                    ($NodeName -eq "UK1ABC") -and ($VaultName -eq "creds_ou_remediation") -and ($VaultItemName -eq "ou_remediation")
                }
                Mock -CommandName Update-ChefVaultForNodeName -MockWith {}

                {Grant-NodeAccessToChefVaults -NodeName "uk1abc"} | Should Not Throw
                Assert-MockCalled Update-ChefVaultForNodeName -Times 1 -ParameterFilter {
                    ($NodeName -eq "UK1ABC") -and ($VaultName -eq "creds_ou_remediation") -and ($VaultItemName -eq "ou_remediation")
                }
            }
        }

        Context 'Grant node access to creds_domain_join Chef Vault' {
            It 'Calls Update-ChefVaultForNodeName to set access to creds_domain_join Chef Vault' {
                Mock -CommandName Update-ChefVaultForNodeName -MockWith {} -ParameterFilter {
                    ($NodeName -eq "UK2ABC") -and ($VaultName -eq "creds_domain_join") -and ($VaultItemName -eq "domain_join")
                }
                Mock -CommandName Update-ChefVaultForNodeName -MockWith {}

                {Grant-NodeAccessToChefVaults -NodeName "uk2abc"} | Should Not Throw
                Assert-MockCalled Update-ChefVaultForNodeName -Times 1 -ParameterFilter {
                    ($NodeName -eq "UK2ABC") -and ($VaultName -eq "creds_domain_join") -and ($VaultItemName -eq "domain_join")
                }
            }
        }
    }
}

AfterFeature
