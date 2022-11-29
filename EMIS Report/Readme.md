# Emis Report

This script is to schedule an email report for EMIS cordinators from Heartland Mosaic.  

Copy the files to your scripts directory.

Update the batch file for your path and enter SFTP username and password.  

Update the script with the emails you want to send it. I send to EMIS cordinator and Food service.  

Also copy [SMTP settings](/SMTPSettings/SMTP.ps1) file or add SMTP server to the script.  

You will need [PSFTP](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) Copy to the root of your scripts directory.

Attempt to manually connect to accept the server fingerprint before using batch mode.  

Setup a scheduled Export in MOSAIC with the data you want.  I use;
 ID, last name, first name, app eligibility start date, status and school.

 This file is then accessible on their SFTP site.  
Use Windows task scheduler to run the batch file at an interval your EMIS cordinator would like the report.  
The script will use PSFTP to copy the report to the script directory then powershell to email it and put a copy in a archive folder.  
