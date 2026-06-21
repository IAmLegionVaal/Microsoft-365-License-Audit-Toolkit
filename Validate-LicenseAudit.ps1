#requires -Version 5.1
<#
.SYNOPSIS
Validates Microsoft 365 license-audit prerequisites and current tenant license state.
.DESCRIPTION
Created by Dewald Pretorius. This workflow is read-only and never assigns or
removes licenses. It expects an existing Microsoft Graph connection.
#>
[CmdletBinding()]
param([string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'M365_License_Audit_Reports'))
$ErrorActionPreference='Stop';$ExitHealthy=0;$ExitWarning=1;$ExitPrerequisite=3;$ExitFailure=5
try{
 New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
 $stamp=Get-Date -Format yyyyMMdd_HHmmss
 if(-not(Get-Module -ListAvailable Microsoft.Graph.Identity.DirectoryManagement)){Write-Error 'Install Microsoft.Graph.Identity.DirectoryManagement.';exit $ExitPrerequisite}
 Import-Module Microsoft.Graph.Identity.DirectoryManagement -ErrorAction Stop
 $context=Get-MgContext -ErrorAction SilentlyContinue
 if(-not $context){Write-Error 'Connect to Microsoft Graph before running this validator.';exit $ExitPrerequisite}
 $skus=@(Get-MgSubscribedSku -All -ErrorAction Stop|Select-Object SkuPartNumber,SkuId,ConsumedUnits,@{n='EnabledUnits';e={$_.PrepaidUnits.Enabled}},@{n='SuspendedUnits';e={$_.PrepaidUnits.Suspended}},@{n='AvailableUnits';e={$_.PrepaidUnits.Enabled-$_.ConsumedUnits}})
 $warnings=@($skus|Where-Object{$_.AvailableUnits -lt 0 -or $_.SuspendedUnits -gt 0})
 $result=[ordered]@{Generated=(Get-Date);TenantId=$context.TenantId;Account=$context.Account;SkuCount=$skus.Count;WarningCount=$warnings.Count;Skus=$skus;Status=$(if($warnings.Count){'Warning'}else{'Healthy'})}
 $result|ConvertTo-Json -Depth 7|Set-Content -LiteralPath (Join-Path $OutputPath "license_validation_$stamp.json") -Encoding UTF8
 $skus|Export-Csv -LiteralPath (Join-Path $OutputPath "license_skus_$stamp.csv") -NoTypeInformation -Encoding UTF8
 if($warnings.Count){Write-Warning "$($warnings.Count) SKU records require review.";exit $ExitWarning}
 Write-Host 'Microsoft 365 license validation passed.' -ForegroundColor Green;exit $ExitHealthy
}catch{Write-Error $_.Exception.Message;exit $ExitFailure}
