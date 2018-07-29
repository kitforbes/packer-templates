$ErrorActionPreference = 'Stop'
$ProgressPreference = "SilentlyContinue"

. A:\utilities.ps1

if ((Get-OperatingSystemVersion).Split(".")[0] -ge 6) {
    # Abort if domain joined.
    if (1, 3, 4, 5 -contains (Get-WmiObject win32_computersystem).DomainRole) {
        return
    }

    # Get network connections
    $networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
    $connections = $networkListManager.GetNetworkConnections()

    $connections | ForEach-Object {
        $currentCategory = $_.GetNetwork().GetCategory()
        if ($currentCategory -ne 1) {
            $_.GetNetwork().SetCategory(1)
            Write-Output "$($_.GetNetwork().GetName())'s category changed from '$currentCategory' to '$($_.GetNetwork().GetCategory())'"
        }

        Remove-Variable -Name "currentCategory"
    }
}

Write-Output "", "==> Enabling PSRemoting..."
Enable-PSRemoting -Force

Write-Output "==> Configuring WinRM..."
winrm quickconfig -q

Write-Output "", "==> Configuring WinRM..."
Update-Item -Path "WSMan:\localhost\Client\Auth\Basic" -Value "true"
# winrm set winrm/config/client/auth '@{Basic="true"}'
Update-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value "true"
# winrm set winrm/config/service/auth '@{Basic="true"}'
Update-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value "true"
# winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Update-Item -Path "WSMan:\localhost\Shell\MaxMemoryPerShellMB" -Value "2048"
# winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'

Write-Output "", "==> Restarting WinRM..."
Restart-Service -Name WinRM

Write-Output "==> Add WinRM Firewall rule..."
New-NetFirewallRule -DisplayName "WinRM-HTTP" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow | Out-Null
# netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

Write-Output "==> Disable Server Manager task..."
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask | Out-Null

exit 0
