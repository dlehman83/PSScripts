$filedate = get-date -UFormat %Y-%m-%d-%H%M
Start-Transcript -Path $PSScriptRoot\logs\MFAlog-$filedate.log

#files forconnecting to Azure that run Connect-AzureAD and Connect-MsolService
. $PSScriptRoot\ConnectMSO.ps1
. $PSScriptRoot\Connect.ps1


$token = [Microsoft.Open.Azure.AD.CommonLibrary.AzureSession]::AccessTokens['AccessToken'].AccessToken

$phoneusers = Get-MsolUser -All | Where-Object BlockCredential -eq $false | 
                Select-Object Userprincipalname -ExpandProperty StrongAuthenticationMethods  | 
                Select-Object UserPrincipalName,  IsDefault, MethodType | 
                Where-Object {$_.MethodType -eq "PhoneAppNotification"}

$keyusers = Get-AzureADUserEx -All -Token $token |
            Where-Object Enabled -eq $true |
            Select-Object -ExpandProperty KeyCredentials |
            Where-Object Usage -eq FIDO




$users = @()
foreach ($phone in $phoneusers) {
$upn = $phone.UserPrincipalName
$MFAType = $phone.MethodType

$user = New-Object -TypeName "PSCustomObject"
$user | Add-Member -NotePropertyName UserPrincipalName -NotePropertyValue "$UPN"
$user | Add-Member -NotePropertyName MFAType -NotePropertyValue "$MFAType"

$users += $user
}

foreach ($key in $keyusers) {
$upn = $key.Owner
$MFAType = $key.Usage

$user = New-Object -TypeName "PSCustomObject"
$user | Add-Member -NotePropertyName UserPrincipalName -NotePropertyValue "$upn"
$user | Add-Member -NotePropertyName MFAType -NotePropertyValue "$mfatype"

$users += $user
}

$users = $users | select UserPrincipalName -Unique

function report {
#Setup Email Report
$mail = New-Object system.net.Mail.MailMessage 
$mail.From  = "yourscriptfrom address"
$mail.To.add("youremail")

$mail.Subject = $subject 
$mail.Body = $body 

$mail.IsBodyHtml
. $PSScriptRoot\..\SMTPSettings\SMTP.ps1
$smtp.send($mail)

}

$mfagroup = Get-ADGroup -Identity "MFAPilot"
$staffgroup = Get-ADGroup -Identity "Staff"
$2fagroup = Get-ADGroup -Identity "2FA"

$mfamembers = Get-ADGroupMember -Identity $mfagroup


$staffmembers = Get-ADGroupMember -Identity $staffgroup
$2famembers = Get-ADGroupMember -Identity $2fagroup

$addedusers = @()
foreach ($user in $users){
$username = $user.UserPrincipalName -replace ('@yourdomain','')


if ($username -in  $staffmembers.SamAccountName) {


if ($username -in  $2famembers.SamAccountName) {



continue}
if ($username -in  $mfamembers.SamAccountName) {


continue}


Add-ADGroupMember -Identity $mfagroup -Members $username


$addedusers += "$username `n"

Write-Host "Adding User $Username"

}



}


$date = Get-Date -UFormat %Y-%m-%d
$subject = "Users Added to MFA Group $date"

$body = "
Users added to MFA Group
$addedusers


"


if ($addedusers.Count -ne 0){


report
}

stop-Transcript