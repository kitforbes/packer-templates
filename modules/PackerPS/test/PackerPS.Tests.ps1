#Requires -Modules Pester
. $PSScriptRoot\Shared.ps1

BeforeFeature

Describe $module -Tags ('unit') {
    Context 'The module manifest' {
        It 'Passes ''Test-ModuleManifest''' {
            Test-ModuleManifest -Path $moduleManifest
            $? | Should Be $true
        }

        It "Has the root module $module.psm1" {
            "$moduleDir\$module.psm1" | Should Exist
        }

        It "Has the manifest file for $module.psm1" {
            "$moduleDir\$module.psd1" | Should Exist
            "$moduleDir\$module.psd1" | Should FileContentMatch "$module.psm1"
        }

        It "$module has valid PowerShell code" {
            $psFile = Get-Content -Path "$moduleDir\$module.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should Be 0
        }

        It "$module manifest has valid PowerShell code" {
            $psFile = Get-Content -Path "$moduleDir\$module.psd1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }

    $privateFunctions = @()
    if (Test-Path -Path (Join-Path -Path $moduleDir -ChildPath 'private')) {
        $privateFunctions = @(Get-ChildItem -Path "$moduleDir\private" -Filter '*.ps1' -File)
    }

    $publicFunctions = @()
    if (Test-Path -Path (Join-Path -Path $moduleDir -ChildPath 'public')) {
        $publicFunctions = @(Get-ChildItem -Path "$moduleDir\public" -Filter '*.ps1' -File)
    }

    foreach ($function in @($privateFunctions + $publicFunctions)) {
        Context "The function '$($function.BaseName)'" {
            It 'Should exist' {
                $function.FullName | Should Exist
            }

            It 'Should be an advanced function' {
                $function.FullName | Should FileContentMatch 'function'
                $function.FullName | Should FileContentMatch 'cmdletbinding'
                $function.FullName | Should FileContentMatch 'param'
            }

            It 'Should contain ''Write-Verbose'' blocks' {
                $function.FullName | Should FileContentMatch 'Write-Verbose'
            }

            It 'Has valid PowerShell code' {
                $psFile = Get-Content -Path $function.FullName -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.Count | Should Be 0
            }
        }
    }

    # TODO: Enable these tests once we figure out how to correctly use PlatyPS.
    # foreach ($function in $publicFunctions) {
    #     Context "The public function '$($function.BaseName)'" {
    #         It 'Should have a help block' {
    #             $function.FullName | Should FileContentMatch '<#'
    #             $function.FullName | Should FileContentMatch '#>'
    #         }

    #         It 'Should have a ''Synopsis'' section in the help block' {
    #             $function.FullName | Should FileContentMatch '.Synopsis'
    #         }

    #         It 'Should have a ''Description'' section in the help block' {
    #             $function.FullName | Should FileContentMatch '.Description'
    #         }

    #         It 'Should have an ''Example'' section in the help block' {
    #             $function.FullName | Should FileContentMatch '.Example'
    #         }
    #     }
    # }
}

AfterFeature
