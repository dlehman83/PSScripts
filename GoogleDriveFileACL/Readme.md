# Google Drive File ACLs
This script will parse a gam export of fileacls into a format to be deleted by another gam command.  
I use this to stop sharing  documents for staff and students who have left.  

I have the script in the same directory as gam and use relative paths.  

## Ussage examples

Gam command to get the report adjust for you OU and filename.  

``` 
gam ou_and_children /Students/HS/GR12/2022 print filelist id title permissions owners > 2022filelistperms.csv

```

Run this file through the powershell script providing an output file name.  

``` PowerShell
.\fileacl.ps1 -fileaclcsv .\2022filelistperms.csv -deletecsv .\2022del.csv
```

Look though the output file to make sure you are deling the file permissions you want.   

run this gam command to delete the file permissions in the above file.  

```
gam csv 2022del.csv gam user "~Owner" delete drivefileacl "~driveFileId" "~permissionId"

```


