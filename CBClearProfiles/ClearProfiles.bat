cd c:\gama
gam print cros nolists showdvrsfp  fields deviceid org serialnumber lastSync diskVolumeReports query status:provisioned > crosdisk.csv      
powershell -file C:\gama\diskreport.ps1
gam csv diskreport.csv  gam  issuecommand cros ~deviceId command wipe_users doit