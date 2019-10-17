function Add-Communicator {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]
        $Template,
        [Parameter(Mandatory = $false)]
        [ValidateSet('ssh', 'winrm')]
        [String]
        $Communicator = 'winrm',
        [Parameter(Mandatory = $false)]
        # [ValidatePattern('\d(s|h|m)')]
        [String]
        $CommunicatorTimeout = '12h',
        [Parameter(Mandatory = $false)]
        [String]
        $CommunicatorUsername = 'vagrant',
        [Parameter(Mandatory = $false)]
        [String]
        $CommunicatorPassword = 'vagrant'
    )

    begin {
        $Template | Add-Member -MemberType NoteProperty -Name 'communicator' -Value $Communicator
        $Template | Add-Member -MemberType NoteProperty -Name "$($Communicator)_timeout" -Value $CommunicatorTimeout
        $Template | Add-Member -MemberType NoteProperty -Name "$($Communicator)_username" -Value $CommunicatorUsername
        $Template | Add-Member -MemberType NoteProperty -Name "$($Communicator)_password" -Value $CommunicatorPassword

        return $Template
    }
}
