$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
if ($Env:PACKER_VERBOSE) { $VerbosePreference = "Continue" }

. A:\utilities.ps1

Write-Output -InputObject "==> Cleaning updates..."
Stop-Service -Name wuauserv -Force
Remove-Item C:\Windows\SoftwareDistribution\Download\* -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name wuauserv

Write-Output -InputObject "", "==> Cleaning WinSxS with Dism..."
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase

Write-Output -InputObject "", "==> Removing non-essential content..."
@(
    "$env:LocaApppData\Nuget",
    "$env:LocaApppData\temp\*",
    "$env:SystemRoot\logs",
    "$env:SystemRoot\temp\*",
    "$env:SystemRoot\winsxs\manifestcache"
) | ForEach-Object {
    if (Test-Path -Path $_) {
        Write-Output -InputObject "Removing $_"
        try {
            # Recursively assign ownership to the vagtant user.
            Takeown /D Y /R /F $_ | Out-Null
            # Recursively grant full access permissions for administrators.
            Icacls $_ /grant:r administrators:F /T /C /Q | Out-Null
            Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
        }
        catch {
            $global:Error.RemoveAt(0)
        }
    }
}

Write-Output -InputObject "", "==> Defragging disk..."
if (Test-Command -Name 'Optimize-Volume') {
    Optimize-Volume -DriveLetter c
}
else {
    Defrag.exe c: /H
}

Write-Output -InputObject "", "==> Overwrite empty space..."
$FilePath = "C:\zero.tmp"
$Volume = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$ArraySize = 64kb
$SpaceToLeave = $Volume.Size * 0.05
$FileSize = $Volume.FreeSpace - $SpacetoLeave
$ZeroArray = New-Object Byte[]($ArraySize)

$Stream = [System.IO.File]::OpenWrite($FilePath)
try {
    $CurFileSize = 0
    while ($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray, 0, $ZeroArray.Length)
        $CurFileSize += $ZeroArray.Length
    }
}
finally {
    if ($Stream) {
        $Stream.Close()
    }

    Remove-Item -Path $FilePath -Force
}

