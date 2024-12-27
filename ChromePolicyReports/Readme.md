# Chrome Policy Reports

This script will call GAM to download Chrome Policies into a csv.  
The default gam to csv spreads the policies out across several columns making it difficult to compare.  
The script flattens it into just a few columns.  

## Requirements  

[GAMADV-XTD3](https://github.com/taers232c/GAMADV-XTD3) or [GAM 7.0+](https://github.com/GAM-team/GAM) is needed.

The script will look for gam in the script directory.  You can set the $gampath varable if it is different.  

## Ussage

Download a list of all OUs

```Powershell
.\chromepolicyreport.ps1 -UpdateOUs
```

Run the script

```Powershell
.\chromepolicyreport.ps1
```

The script will loop though all of the OUs in the CSV getting the policies into csv
It will also try to lookup the app ids from the chrome webstore.
Any OUs without polices will be removed from OUs.csv to speed up future runs.

## Files

| File|Use |
|-|-|
| versiontest.txt | Verify GAM version |
| ous.csv | OUs to loop through |
| appids.csv | Appids lookup file |
| ChromePolicyReport.csv | Report of Chrome Polices |
| apps.csv | Report of Chrome Apps |
