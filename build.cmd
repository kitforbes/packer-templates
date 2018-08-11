@PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0%~n0.ps1' %*"
@if '%ERRORLEVEL%' EQU '0' (exit /B 0) else (exit /B 1)
