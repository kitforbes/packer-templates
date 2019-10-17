function New-HyperVIsoBuilder {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $false)]
        [String]
        $Name,
        [Parameter(Mandatory)]
        [String]
        $OutputDirectory,
        [Parameter(Mandatory = $false)]
        [String]
        $VmName,
        [Parameter(Mandatory)]
        [String]
        $IsoUrl,
        [Parameter(Mandatory = $false)]
        [String]
        $IsoChecksum,
        [Parameter(Mandatory = $false)]
        [ValidateSet('md5')]
        [String]
        $IsoChecksumType = 'md5',
        [Parameter(Mandatory = $false)]
        [ValidateSet('ssh', 'winrm')]
        [String]
        $Communicator = 'winrm',
        [Parameter(Mandatory = $false)]
        [String]
        $CommunicatorTimeout = '12h',
        [Parameter(Mandatory = $false)]
        [String]
        $CommunicatorUsername = 'vagrant',
        [Parameter(Mandatory = $false)]
        [String]
        $CommunicatorPassword = 'vagrant',
        [Parameter(Mandatory = $false)]
        [String[]]
        $FloppyFiles = @(),
        [Parameter(Mandatory = $false)]
        [Switch]
        $DifferencingDisk,
        [Parameter(Mandatory = $false)]
        [Switch]
        $SkipExport
    )

    begin {
        $template = [PSCustomObject] @{
            'type'             = "hyperv-iso"
            'generation'       = 1
            'boot_wait'        = "0s"
            'boot_command'     = @(
                "a<wait>a<wait>a"
            )
            'shutdown_command' = "shutdown /s /t 10 /f /d p:4:1 /c \`"Packer Shutdown\`""
            'shutdown_timeout' = "1h"
        }

        if ($Name) {
            $template | Add-Member -MemberType NoteProperty -Name 'name' -Value $Name
        }

        $output = [PSCustomObject] @{
            'output_directory'  = "$OutputDirectory/{{ user `os_name` }}-{{ user `stage` }}-hyperv/"
            'vm_name'           = $VmName
            'iso_url'           = $IsoUrl
            'iso_checksum'      = $IsoChecksum
            'iso_checksum_type' = $IsoChecksumType
            'floppy_files'      = $FloppyFiles
            'cpu'               = 1
            'disk_size'         = 81920
            'ram_size'          = 4096
            'differencing_disk' = $DifferencingDisk
            'skip_export'       = $SkipExport
        }

        $template = $template | Add-Communicator
        return $template
    }
}
