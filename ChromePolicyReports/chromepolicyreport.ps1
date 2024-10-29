<#
.SYNOPSIS

Pull all policies from Google admin into csv reports

.DESCRIPTION

Get list of OUs from GAM
Loop though OUS and download all policies 
Lookup app names from Chrome webstore
Create csv reports of apps and policies

.PARAMETER UpdateOUs
Updates the list of OUs, if they have changed
.PARAMETER testing
Reprocess the downloaded json files without going back  to Google
Useful for updating app names or debugging


.OUTPUTS

Creates 4 csv files
apps.csv for a list of installed app
appids.csv for a list of appid to name lookup
policy report showing all the directly applied policies
ous.csv a list of all OUs to get policies from

.EXAMPLE

PS> .\chromepolicyreport.ps1
Will run a normal report

.EXAMPLE

PS> .\chromepolicyreport.ps1-updateOUs
Update the list of OUs


.LINK
https://github.com/dlehman83/PSScripts/tree/main/ChromePolicyReports
.NOTES
Author: dlehman83
Created 2024-10-22

Written with GAMADV-XTD3 6.80.10

Also tested with GAM 7.00.30

#>

param (
    [switch]$UpdateOUs = $false,

    [switch]$testing = $false)

Set-Location $PSScriptRoot
#File Paths
$gampath = "$PSScriptRoot\gam.exe"
$gamver = "$PSScriptRoot\versiontest.txt"
$oufile = "$PSScriptRoot\ous.csv"
$newoufile = "$PSScriptRoot\newous.csv"
$polfolder = "$PSScriptRoot\policyfiles"
$appidfile = "$PSScriptRoot\appids.csv"
$reportfile = "$PSScriptRoot\ChromePolicyReport.csv"
$appslistfile = "$PSScriptRoot\apps.csv"

if (!(test-path $polfolder)) {
    New-Item -Path $polfolder -ItemType Directory
}

function get-appid {
    $URI = 'https://chrome.google.com/webstore/detail/'
    $app_ID = $appid

    $data = Invoke-WebRequest -Uri ($URI + $app_ID) | Select-Object -Property Content
    $data = $data.Content
   
    $title = [regex] '(?<=og:title" content=")([\S\s]*?)(?=">)' 
    $appname = $title.Match($data).value.trim()
   
   
    $app = [PSCustomObject]@{
        ID   = $app_ID
        name = $appname
   
    }

    return $app

}

#Test gam path
if (!(test-path $gampath)) {
    Write-Host "GAM not found" -ForegroundColor Red 
    Write-Host "Run from same path as GAM, or set gam path at top of script" -ForegroundColor Yellow
    break

}

#Test gam version
& $gampath --version > $gamver

$ver = Get-Content $gamver -Raw

if ($ver -like "*Jay0lee@gmail.com*") {
    Write-Host "WARNING: GAMADV-XTD3 OR GAM7 is required for this script" -ForegroundColor Yellow
    break

}

try {
    $appids = Import-Csv $appidfile  
}
catch {
    Write-Host "Missing appids file"
}

#save OUs
if ($UpdateOUs -eq $true) {
    Write-Host "Update OUs" -ForegroundColor Cyan
    & $gampath print orgs > $oufile 
    $ous = import-csv $oufile 
    $ous | Select-Object -Property orgUnitPath | Export-Csv -NoTypeInformation $oufile 
}


$polreprt = @()
$apps = @()
$ous = Import-Csv $oufile
#create root OU entry as gam doesn't create it.
$rootou = [PSCustomObject]@{
    orgUnitPath = "all"
}
#Add root OU to the list of OUs 
if ($ous.orgUnitPath -notcontains "all") {
    $ous += $rootou

}

#Get root ou policies and clear old policy files
#Clear policies for fresh run
if ($testing -eq $false) {
    # Write-Host "Updating policy for root OU" -ForegroundColor Cyan
    Remove-Item -Path $polfolder\*.json -Recurse 
    # & $gampath show chromepolicy orgunit /  formatjson  > "$polfolder\all.json"
}
$newous = @()
foreach ($ou in $ous) {
    $name = $ou.orgUnitPath -replace ("/", "")
    $oupath = $ou.orgUnitPath
    if ($oupath -eq "All") { $oupath = "/" }

    $polfile = "$polfolder\$name.json"

    if ($testing -eq $false) {
        Write-Host "Updating policies from GAM for $oupath" -ForegroundColor Cyan

        & $gampath show chromepolicy orgunit $oupath  show direct formatjson  > $polfile

    }

    $fc = get-content $polfile
    $linecount = $null
    $linecount = $fc | Measure-Object -Line

    if ( $linecount.Lines -eq 0 ) {
        
        Remove-Item $polfile
        
        continue
    
    }


    $json = $fc | ConvertFrom-Json
    #Write new OU file omitting OUs without policies.
    $newous += $ou

    foreach ($val in $json) {

        #policies
        if ($val.additionalTargetKeys.Length -eq 0) {
    
            $polreprt += $val  | Select-Object  -Property @{n = "PolName"; e = { $_.name } }, direct, orgUnitPath, parentOrgUnitPath -ExpandProperty fields
    
        }
    
        #App install list
        if ($val.additionalTargetKeys[0].name -eq "App_id" -and $val.fields.name -eq "appInstallType") {
            $appid = $val.additionalTargetKeys[0].value.Split(':')[1]
            $appname = $null
            $appname = $appids | Where-Object { $_.id -eq $appid } | Select-Object -ExpandProperty name
    
            #Try to get app name from chrome web store if not already in appidfile
            if ($null -eq $appname) {
                $newapp = $null
                $newapp = get-appid $appid
                if ($newapp.name -eq "Chrome Web Store") {
                    $newapp.name = "App not found in store"
    
                }
                if ($newapp.name -like "*- Chrome Web Store") {
        
                    $newapp.name = ($newapp.name -split '-')[0]
    
                }
       
                $appname = $newapp.name
                $appids += $newapp
                $newapp 
    
            }
    
            $app = [PSCustomObject]@{
                AppID             = $appid
                Appname           = $appname
                direct            = $val.direct
                orgUnitPath       = $val.orgUnitPath
                parentOrgUnitPath = $val.parentOrgUnitPath
                Installtype       = $val.fields[0].value
                polname           = $val.name
            }
    
            $apps += $app
    
    
        }
    
        #App Config
        if ($val.additionalTargetKeys[0].name -eq "App_id" -and $val.fields.name -ne "appInstallType") {
            $appid = $val.additionalTargetKeys[0].value.Split(':')[1]
            $appname = $appids | Where-Object { $_.id -eq $appid } | Select-Object -ExpandProperty name
            $polname = "Chrome.app.$appname"
            $apppol = [PSCustomObject]@{
            
                name              = $appid
                value             = $val.fields[0].value
                PolName           = $polname
                direct            = $val.direct
                orgUnitPath       = $val.orgUnitPath
                parentOrgUnitPath = $val.parentOrgUnitPath
            
            
            }
    
            $polreprt += $apppol
      
    
        }
    
        #network_id
        if ($val.additionalTargetKeys[0].name -eq "network_id" -and $val.fields.name -eq "details") {
    
            $netdetails = $null
            $netdetails = $val.fields  | Select-Object -ExpandProperty value
    
    
    
            $netpol = [PSCustomObject]@{
            
                name              = $netdetails.name
                value             = $netdetails
                PolName           = $val.name
                direct            = $val.direct
                orgUnitPath       = $val.orgUnitPath
                parentOrgUnitPath = $val.parentOrgUnitPath
            
            }
            $polreprt += $netpol
    
        }
    
    
        #End value loop
    }

}

Write-host "Saving policy report to $reportfile"
$polreprt | Sort-Object -Property parentOrgUnitPath, PolName  | Export-Csv -NoTypeInformation $reportfile
Write-Host "Saving Apps list to $appslistfile"
$apps | Sort-Object -Property parentOrgUnitPath, appname |   Export-Csv $appslistfile -NoTypeInformation
Write-Host "Saving / updating apppids file $appidfile"
$appids | Export-Csv -NoTypeInformation $appidfile
Write-Host "Updating OU file $newoufile" 
#$newous | Export-Csv -NoTypeInformation $newoufile
$newous | Select-Object -Property orgUnitPath | Export-Csv -NoTypeInformation $oufile

Write-Host "Done" -ForegroundColor Green