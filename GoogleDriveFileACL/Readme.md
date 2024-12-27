# Google Drive File ACLs

This script will parse a gam export of fileacls into a format to be deleted by another gam command.  
I use this to stop sharing  documents for staff and students who have left.  

Added examples to help find oversharing of public documents.

Added fileaclpublic, it will filter for public and domain docs.  
Added the last modified user and time, moved colum order to be more relevant for non tech staff review.  

I have the script in the same directory as gam and use relative paths.  

## Usage examples

Gam command to get the report of all user shares from an OU adjust for you OU and filename.  

``` cmd
gam ou_and_children /Students/HS/GR12/2024 print filelist id title permissions owners > 2024filelistperms.csv

```

Find public documents for staff OU

``` cmd
gam ou_and_children /Staff/ print filelist  query "visibility='anyoneCanFind' or visibility='anyoneWithLink'"  id title permissions owners filepath lastModifyingUser.emailAddress modifiedTime  > staffpublicacl.csv
```

Find public and domain documents for one user

``` cmd
gam user username@example.com print filelist  query "visibility='anyoneCanFind' or visibility='anyoneWithLink' or visibility='domainCanFind' or visibility='domainWithLink' "  id title permissions owners filepath lastModifyingUser.emailAddress modifiedTime  > userfileacl.csv
```

[Google Drive Query Documentation](https://developers.google.com/drive/api/guides/ref-search-terms)

Run this file through the powershell script providing an output file name.  

``` PowerShell
.\fileacl.ps1 -fileaclcsv .\2024filelistperms.csv -deletecsv .\2024del.csv
```

Look through the output file to make sure you are deleting the file permissions you want.

Run this gam command to delete the file permissions in the above file.  

``` cmd
gam csv 2024del.csv gam user "~Owner" delete drivefileacl "~driveFileId" "~permissionId"

```

## Bonus Google Drive Search

Here is a Google drive search to share with users

``` cmd
owner:me sharedwith:public
```
