#requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$InputCsv,[int]$WarningPercent=80,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'SharePoint_Storage_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
if(-not (Test-Path $InputCsv)){Write-Error 'Input CSV not found.';return}
$sites=Import-Csv $InputCsv|ForEach-Object{$used=[double]$_.StorageUsedGB;$quota=[double]$_.StorageQuotaGB;$pct=if($quota -gt 0){[math]::Round(($used/$quota)*100,2)}else{0};[PSCustomObject]@{Title=$_.Title;Url=$_.Url;Owner=$_.Owner;StorageUsedGB=$used;StorageQuotaGB=$quota;StoragePercent=$pct;Status=$(if($pct -ge $WarningPercent){'Review'}else{'OK'})}}
$sites|Export-Csv (Join-Path $OutputPath "sharepoint_storage_$stamp.csv") -NoTypeInformation -Encoding UTF8
$sites|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "sharepoint_storage_$stamp.json") -Encoding UTF8
$html="<h1>SharePoint Storage Usage</h1><p>Generated $(Get-Date)</p>$($sites|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'SharePoint Storage Usage'|Set-Content (Join-Path $OutputPath "sharepoint_storage_$stamp.html") -Encoding UTF8
$sites|Format-Table -AutoSize
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
