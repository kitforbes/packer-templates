# Packer Templates

This repository attempts to generalize the Packer process to reduce repetition and duplication.

## Execution Times

Times are in minutes.

### Windows Server 2012 R2

Provider | Stage 1 | Stage 2 | Stage 3
:--------|--------:|--------:|--------:
Hyper-V  |       8 |     225 |     100


## PowerShell Modules

```powershell
dotnet build
```

```powershell
Import-Module modules/...
```
