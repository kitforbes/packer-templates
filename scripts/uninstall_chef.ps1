$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
if ($Env:PACKER_VERBOSE) { $VerbosePreference = "Continue" }

. A:\utilities.ps1

$attempt = 0
while ($true) {
    $product = Get-CimInstance -ClassName Win32_Product -Namespace root/cimv2 -Filter "Name like 'Chef Client%'"
    $process = $product | Invoke-CimMethod -MethodName Uninstall
    if ($process.ReturnValue -eq 1618) {
        $attempt++
        Write-Output -InputObject "Another msiexec process is in progress (attempt: $attempt)"
        if ($attempt -le 6) {
            Start-Sleep -Seconds 30
            continue
        }
        elseif ($attempt -gt 6 -and $attempt -le 13) {
            Start-Sleep -Seconds 60
            continue
        }
        else {
            Write-Output -InputObject "Uninstall failed."
            throw
        }
    }
    elseif ($process.ReturnValue -ne 0) {
        Write-Output -InputObject "Uninstall failed ($process.ReturnValue)."
        throw
    }
    else {
        Write-Output -InputObject "Uninstall complete."
        break
    }
}

Write-Output -InputObject "", "==> Attempting to remove Chef directories..."
Remove-Directory -Path "C:\chef"
# Remove-Directory -Path "C:\opscode\chef"

# $result = Invoke-Process -FilePath "inspec" -ArgumentList "-v"
# if ($result -ne 0) { exit $result }

# $result = Invoke-Process -FilePath "inspec" -ArgumentList "exec", "https://github.com/dev-sec/windows-patch-baseline"
# if ($result -ne 0) { exit $result }

# $result = Invoke-Process -FilePath "choco" -ArgumentList "uninstall", "inspec", "--all-versions", "--yes"
# if ($result -ne 0) { exit $result }

# Write-Output -InputObject "", "==> Attempting to remove opscode directory..."
Remove-Directory -Path "C:\opscode"
exit 0
