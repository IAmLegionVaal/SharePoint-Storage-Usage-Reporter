# SharePoint Storage Usage Reporter

A read-only PowerShell toolkit for SharePoint site storage inventory and review.

## Features

- CSV import mode for offline portfolio demonstrations
- Storage-used and quota percentage calculations
- Threshold-based site review reporting
- CSV, JSON, and HTML reports

## Run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\SharePoint_Storage_Usage_Reporter.ps1 -InputCsv .\sites.csv
```

## Safety

Read-only and reporting-focused. No SharePoint settings are changed.
