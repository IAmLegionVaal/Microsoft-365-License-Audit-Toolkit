#requires -Version 5.1
<#
.SYNOPSIS
    Microsoft 365 License Audit Toolkit.
.DESCRIPTION
    Read-only Microsoft 365 license review and reporting helper.
#>
[CmdletBinding()]
param([string]$InputCsv,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'M365_License_Reports'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
$module=Get-Module -ListAvailable Microsoft.Graph -ErrorAction SilentlyContinue|Select-Object -First 1
$checks=@([PSCustomObject]@{Area='Module';Name='Microsoft.Graph';Status=$(if($module){'OK'}else{'Info'});Value=$(if($module){$module.Version}else{'Not installed'});Recommendation='Install when live tenant reporting is required.'})
if($InputCsv -and (Test-Path $InputCsv)){$data=Import-Csv $InputCsv}else{$data=@([PSCustomObject]@{UserPrincipalName='sample.user@contoso.com';DisplayName='Sample User';LicenseSku='M365_BUSINESS_PREMIUM';AccountEnabled='True'})}
$data|Export-Csv (Join-Path $OutputPath "license_inventory_$stamp.csv") -NoTypeInformation -Encoding UTF8
$data|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "license_inventory_$stamp.json") -Encoding UTF8
$checks|Export-Csv (Join-Path $OutputPath "readiness_checks_$stamp.csv") -NoTypeInformation -Encoding UTF8
$template='Review unlicensed active users','Review licensed inactive users','Review duplicate service plans','Review trial licenses','Review disabled users with licenses','Review available license capacity'|ForEach-Object{[PSCustomObject]@{ReviewItem=$_;Status='Not assessed';Notes=''}}
$template|Export-Csv (Join-Path $OutputPath "license_review_template_$stamp.csv") -NoTypeInformation -Encoding UTF8
$html="<h1>Microsoft 365 License Audit</h1><p>Generated $(Get-Date)</p><h2>Readiness</h2>$($checks|ConvertTo-Html -Fragment)<h2>License Inventory</h2>$($data|ConvertTo-Html -Fragment)<h2>Review Template</h2>$($template|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'M365 License Audit'|Set-Content (Join-Path $OutputPath "m365_license_audit_$stamp.html") -Encoding UTF8
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
