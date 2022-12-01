param(
[string]$fileaclcsv,
[string]$deletecsv
)




Import-Csv $fileaclcsv | ForEach-Object -Process{

$row = $_

$numperms = $_.permissions -1

        foreach ($i in 0.. $numperms){

        #skip owners
        if ($row."permissions.$i.role" -eq "Owner") {continue}
 
        
             $Properties = [Ordered] @{
                    "Owner" = $Row.owner
                    "driveFileId"   = $Row.ID
                    "driveFileTitle" = $Row.title
                    "permissionId" =  "id:" + $row."permissions.$i.id"
                    "type" = $row."permissions.$i.type"
                    "role" = $row."permissions.$i.role"
                    "emailAddress" = $row."permissions.$i.emailAddress"
                    "addroles" = $row."permissions.$i.additionalRoles"
                    "link" = $row."permissions.$i.withLink"
                    "perm num" = $i
                   

                    
                                      
             }



New-Object PSObject -Property $Properties
        

        
        }





} |

 ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $deletecsv -Encoding ascii -Append

