$ErrorActionPreference = 'Stop'

Get-WindowsUpdate -WindowsUpdate -AcceptAll -Install -IgnoreReboot

exit 0
