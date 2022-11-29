$date = get-date -UFormat %Y-%m-%d-%H%M
function report {
#Setup Email Report
$mail = New-Object system.net.Mail.MailMessage 
$mail.From  = "your from address "
$mail.To.add("an email address")
$mail.To.add("an email address")
$mail.Subject = $subject 
$mail.Body = $body 
$mail.Attachments.Add($emisarchivefile)
# I keep SMTP settings in another file
#uncomment this line if not using the SMTP Settings file
#$smtp = new-object system.Net.Mail.SmtpClient("your smtp server")
#this line calls the SMTP settings file don't use both.  
. $PSScriptRoot\..\SMTPSettings\SMTP.ps1
$smtp.send($mail)
}
$PSScriptRoot
$emisfile = "$PSScriptRoot\emis.csv"
$emisarchivefile = "$PSScriptRoot\archive\$date-emis.csv"

#check for file
$emis = Get-Content $emisfile

if ($null -eq $emis ){

$subject = "Mosaic EMIS Report FAILED " + $date 
$body = "emis report  file blank check Mosaic Export"
report
exit}

#backup report  files with date stamp
Copy-Item $emisfile $emisarchivefile

# send email report
$subject = "Mosaic EMIS Report " + $date 
$body = "Please find attached the EMIS report from Mosaic."
report
#remove old report
Remove-item $emisfile -Force