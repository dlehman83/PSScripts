clear
$crosfile = "$PSScriptRoot\crosdisk.csv"
$reportfile = "$PSScriptRoot\diskreport.csv"

$crospath = Get-ChildItem $crosfile

$date = Get-Date
$date = $date.AddDays(-7)



$header = [Linq.Enumerable]::Take([System.IO.File]::ReadLines($crospath.FullName),1)
$count = ($header -split ',').Count
$volcount = ($count -4)/4 -1

Remove-Item -Path $reportfile -Force
[long]$gig = 1073741824
Import-Csv $crosfile| ForEach-Object -Process{
$cb = $_

$syncdate = $cb.lastSync

$syncdate = get-date $syncdate

if ($syncdate -lt $date) {return}

foreach ($i in 0.. $volcount){

$volid = $cb."diskVolumeReports.volumeInfo.$i.volumeId"

if ( $volid -notlike "/home*/MyFiles") {return}

[long]$free = $cb."diskVolumeReports.volumeInfo.$i.storageFree" # /1024 /1024 
[long]$freemb = $cb."diskVolumeReports.volumeInfo.$i.storageFree" /1024 /1024 
[long]$total = $cb."diskVolumeReports.volumeInfo.$i.storageTotal"  /1024 /1024 /1024

$percent = $cb."diskVolumeReports.volumeInfo.$i.storageFreePercentage"

if ($free -gt $gig -and $percent -gt 10) {return}
$org = $cb.orgUnitPath
$Properties = [Ordered] @{
                    "deviceId" = $cb.deviceId
                    "serialNumber"   = $cb.serialNumber
                    "lastSync" = $cb.lastSync
                    "Total" =  $total
                    "free" = $free
                    "percentfree" = $percent
                    "name" = $volid
                    "org" = $org
                    "volnum" = $i
                
                    } 
                    

                    New-Object PSObject -Property $Properties
                   
                    }


                    } |

ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $reportfile -Encoding ascii -Append
