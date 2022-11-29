$filedate = get-date -UFormat %Y-%m-%d-%H%M
Start-Transcript -Path $psscriptroot\logs\log-$filedate.log
$date = get-date 
$users = get-aduser -Filter {enabled -eq $true} -Properties AccountExpires,mail 
foreach ($user in $users){
    #has expiry date
if ($user.AccountExpires -lt 200000000000000000 -and $user.AccountExpires -gt 100000000000000000){
    #has email skipping service accounts
if ($user.mail -notlike "*@example.com"){continue}
$expiry = Get-ADUser -Identity $user -Properties accountexpirationdate | Select-Object -expandproperty accountexpirationdate 
if ($expiry -lt $date){
#$user |select-object name, @{N="AccountExpires";E={[DateTime]::FromFileTime($_.AccountExpires)}}
write-output $user
Disable-ADAccount  $user
}}}
stop-Transcript