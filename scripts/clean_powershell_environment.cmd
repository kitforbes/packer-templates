@setlocal EnableDelayedExpansion EnableExtensions
@if defined PACKER_VERBOSE ( @echo on ) else ( @echo off )

if exist "C:\Program Files\WindowsPowerShell\Modules\PowerShellGet\1.0.0.1"  (
    echo. && echo ==^> Removing PowerShellGet v1.0.0.1...
    rmdir /S /Q "C:\Program Files\WindowsPowerShell\Modules\PowerShellGet\1.0.0.1"
    if '%ERRORLEVEL%' NEQ '0' ( exit /B %ERRORLEVEL% )
)

if exist "C:\Program Files\WindowsPowerShell\Modules\PackageManagement\1.0.0.1" (
    echo. && echo ==^> Removing PackageManagement v1.0.0.1...
    rmdir /S /Q "C:\Program Files\WindowsPowerShell\Modules\PackageManagement\1.0.0.1"
    if '%ERRORLEVEL%' NEQ '0' ( exit /B %ERRORLEVEL% )
)

if defined PACKER_VERBOSE (
    echo. && echo ==^> Remaining modules...
    powershell -Command "Get-Module -ListAvailable -Verbose:$false | Out-String; return $LastExitCode"
    if '%ERRORLEVEL%' NEQ '0' ( exit /B %ERRORLEVEL% )
)

exit /B 0
