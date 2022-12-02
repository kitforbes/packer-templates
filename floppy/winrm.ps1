$ErrorActionPreference = 'Stop'
$ProgressPreference = "SilentlyContinue"
if ($Env:PACKER_VERBOSE) { $VerbosePreference = "Continue" }

. A:\utilities.ps1

if ((Get-OperatingSystemVersion).Split(".")[0] -ge 6) {
    # Abort if domain joined.
    if (1, 3, 4, 5 -contains (Get-WmiObject win32_computersystem).DomainRole) {
        return
    }

    # Get network connections
    $networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
    $connections = $networkListManager.GetNetworkConnections()

    # Set network connections to private
    $connections | ForEach-Object {
        $currentCategory = $_.GetNetwork().GetCategory()
        if ($currentCategory -ne 1) {
            $_.GetNetwork().SetCategory(1)
            Write-Output -InputObject "$($_.GetNetwork().GetName())'s category changed from '$currentCategory' to '$($_.GetNetwork().GetCategory())'"
        }

        Remove-Variable -Name "currentCategory"
    }
}

Write-Output -InputObject "", "==> Configuring remote access..."
Enable-PSRemoting -Force
Set-WSManQuickConfig -Force
# winrm quickconfig -q

Write-Output -InputObject "", "==> Configuring WinRM..."
Update-Item -Path "WSMan:\localhost\Client\Auth\Basic" -Value "true"
# winrm set winrm/config/client/auth '@{Basic="true"}'
Update-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value "true"
# winrm set winrm/config/service/auth '@{Basic="true"}'
Update-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value "true"
# winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Update-Item -Path "WSMan:\localhost\Shell\MaxMemoryPerShellMB" -Value "2048"
# winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
Update-Item -Path "WSMan:\localhost\MaxTimeoutMS" -Value "1800000"

Write-Output -InputObject "", "==> Restarting WinRM..."
Restart-Service -Name WinRM

Write-Output -InputObject "==> Add WinRM Firewall rules..."
New-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow | Out-Null
# netsh advfirewall firewall add rule name="Windows Remote Management (HTTP-In)" dir=in localport=5985 protocol=TCP action=allow
New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow | Out-Null
# netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in localport=5986 protocol=TCP action=allow

Write-Output -InputObject "==> Disable Server Manager task..."
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask | Out-Null

exit 0
