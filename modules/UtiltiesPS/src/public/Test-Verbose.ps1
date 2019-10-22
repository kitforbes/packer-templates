function Test-Verbose {
    [CmdletBinding()]
    [OutputType([Boolean])]
    param ()

    end {
        return [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
    }
}
