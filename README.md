# Microsoft 365 License Audit Toolkit

A read-only PowerShell toolkit for Microsoft 365 license review preparation.

## Features

- Microsoft Graph module check
- Licensing assessment checklist
- Sample CSV import mode for offline portfolio demonstrations
- CSV, JSON, Markdown, and HTML reports

## How to run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Microsoft_365_License_Audit_Toolkit.ps1
```

Use a sample CSV:

```powershell
.\Microsoft_365_License_Audit_Toolkit.ps1 -InputCsv .\users-and-licenses.csv
```

## Safety

Read-only and documentation-focused. It does not assign or remove licenses.
