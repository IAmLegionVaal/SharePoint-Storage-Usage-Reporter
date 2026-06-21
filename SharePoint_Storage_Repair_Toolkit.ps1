[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
 [switch]$InstallModule,
 [string]$AdminUrl,
 [string]$SiteUrl,
 [int]$StorageMaximumLevelMB,
 [int]$StorageWarningLevelMB,
 [switch]$DryRun,
 [switch]$Yes,
 [string]$OutputPath=(Join-Path $env:LOCALAPPDATA 'SharePointStorageRepair')
)
$ErrorActionPreference='Stop';$script:Failures=0;$script:Actions=0
$run=Join-Path $OutputPath (Get-Date -Format yyyyMMdd_HHmmss);New-Item -ItemType Directory $run -Force|Out-Null
$log=Join-Path $run 'repair.log';$before=Join-Path $run 'before.json';$after=Join-Path $run 'after.json'
function Log($m){"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"|Tee-Object -FilePath $log -Append}
function Act($d,[scriptblock]$a){$script:Actions++;Log $d;if($DryRun){Log "DRY-RUN: $d";return};try{&$a;Log "SUCCESS: $d"}catch{$script:Failures++;Log "FAILED: $d - $($_.Exception.Message)"}}
if(-not($InstallModule -or $StorageMaximumLevelMB -or $StorageWarningLevelMB)){Write-Error 'Choose a module or storage repair action.';exit 2}
if(($StorageMaximumLevelMB -or $StorageWarningLevelMB) -and (-not $AdminUrl -or -not $SiteUrl)){Write-Error '-AdminUrl and -SiteUrl are required for storage changes.';exit 2}
if($StorageMaximumLevelMB -and $StorageMaximumLevelMB -lt 1024){Write-Error 'StorageMaximumLevelMB must be at least 1024.';exit 2}
if($StorageWarningLevelMB -and $StorageMaximumLevelMB -and $StorageWarningLevelMB -ge $StorageMaximumLevelMB){Write-Error 'Warning level must be lower than maximum level.';exit 2}
$module=Get-Module Microsoft.Online.SharePoint.PowerShell -ListAvailable|Select-Object -First 1
[pscustomobject]@{Collected=Get-Date;Module=$module;AdminUrl=$AdminUrl;SiteUrl=$SiteUrl}|ConvertTo-Json -Depth 5|Set-Content $before -Encoding UTF8
if(-not $Yes -and -not $DryRun){if((Read-Host 'Apply selected SharePoint storage changes? Type YES') -ne 'YES'){Log 'Cancelled.';exit 10}}
if($InstallModule){Act 'Installing SharePoint Online Management Shell module' {Install-Module Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force -AllowClobber}}
$needsConnection=[bool]($StorageMaximumLevelMB -or $StorageWarningLevelMB)
if($needsConnection){Act "Connecting to $AdminUrl" {Import-Module Microsoft.Online.SharePoint.PowerShell -ErrorAction Stop;Connect-SPOService -Url $AdminUrl};$existing=if(-not $DryRun){Get-SPOSite -Identity $SiteUrl -Detailed}else{$null};if($existing){$existing|Select-Object Url,StorageUsageCurrent,StorageQuota,StorageQuotaWarningLevel|ConvertTo-Json|Set-Content (Join-Path $run 'site-before.json') -Encoding UTF8};$params=@{Identity=$SiteUrl};if($StorageMaximumLevelMB){$params.StorageQuota=$StorageMaximumLevelMB};if($StorageWarningLevelMB){$params.StorageQuotaWarningLevel=$StorageWarningLevelMB};Act "Updating storage limits for $SiteUrl" {Set-SPOSite @params};if(-not $DryRun){Get-SPOSite -Identity $SiteUrl -Detailed|Select-Object Url,StorageUsageCurrent,StorageQuota,StorageQuotaWarningLevel|ConvertTo-Json|Set-Content (Join-Path $run 'site-after.json') -Encoding UTF8}}
[pscustomobject]@{Collected=Get-Date;Module=Get-Module Microsoft.Online.SharePoint.PowerShell -ListAvailable|Select-Object Name,Version,Path;AdminUrl=$AdminUrl;SiteUrl=$SiteUrl}|ConvertTo-Json -Depth 5|Set-Content $after -Encoding UTF8
if($script:Failures){exit 20};Log "Workflow completed. Actions: $script:Actions";exit 0
