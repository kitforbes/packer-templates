function Obscure-Variables {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [String[]]
        $Variables
    )

    begin {
    }

    process {
        # TODO: Mask variables containing pass or token.
    }

    end {
    }
}
