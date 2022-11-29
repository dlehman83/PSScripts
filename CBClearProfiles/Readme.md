# Clear Chromebook Profiles

## Install / Use

You must already have [GAM](https://github.com/GAM-team/GAM) or [GAMADV-XTD3](https://github.com/taers232c/GAMADV-XTD3)
I tested with GAMADV-XTD3 V6.27.19

Copy files to your gam directory and adjust the path in the .bat file.

Use windows task Scheduler to run the batch file on a schedule.  I run it weekly on Sunday in the early AM.  

The script will use gam to get a report of all provisioned Chromebooks. 
Then Powershell to look through the report finding devices active in the last week with less than 10% and less than 1GB of free disk space.  
Gam again to issue the clear profile command based on the results of the powershell script.  



