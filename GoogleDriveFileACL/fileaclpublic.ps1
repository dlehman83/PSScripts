param(
        [string]$fileaclcsv,
        [string]$deletecsv
)


Remove-Item $deletecsv

Import-Csv $fileaclcsv | ForEach-Object -Process {

        $row = $_

        $numperms = $_.permissions - 1

        foreach ($i in 0.. $numperms) {

                #skip owners
                if ($row."permissions.$i.role" -eq "Owner") { continue }
                
                #find public
                $public = ("anyone", "domain")


                if ($row."permissions.$i.type" -notin $public ) { continue }


                $Properties = [Ordered] @{
                        "Owner"        = $Row.owner
                        "Name"         = $Row.Name
                        "modifiedby"   = $row."lastModifyingUser.emailAddress"
                        "lastmodified" = $row.modifiedTime
                        "type"         = $row."permissions.$i.type"
                        "role"         = $row."permissions.$i.role"
                        "path"         = $row."path.0"
                        "permissionId" = "id:" + $row."permissions.$i.id"
                        "driveFileId"  = $Row.ID
                                      
                }



                New-Object PSObject -Property $Properties
        

        
        }





} |

ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $deletecsv -Encoding ascii -Append

