# SharePoint Storage Usage Reporter

PowerShell tools for SharePoint storage reporting and guarded site-quota corrections.

## Report

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\SharePoint_Storage_Usage_Reporter.ps1 -InputCsv .\sites.csv
```

## Repair

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\SharePoint_Storage_Repair_Toolkit.ps1 -InstallModule -DryRun
```

Example quota update:

```powershell
.\SharePoint_Storage_Repair_Toolkit.ps1 -AdminUrl https://contoso-admin.sharepoint.com -SiteUrl https://contoso.sharepoint.com/sites/Support -StorageMaximumLevelMB 51200 -StorageWarningLevelMB 46080 -DryRun
```

The repair workflow installs the SharePoint Online Management Shell module when requested, connects to the selected administration endpoint, and changes storage maximum or warning levels only for the explicitly selected site. It captures module and site quota state before and after repair and supports `-DryRun`, confirmation, logs and clear exit codes.

## Safety

The tool does not delete content, empty recycle bins, create sites or change tenant-wide storage policy. Verify the site URL and available tenant storage before raising a quota.

## Author

Dewald Pretorius — L2 IT Support Engineer
