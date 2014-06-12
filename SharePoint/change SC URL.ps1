Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue 

#Get the Source Site Collection URL

$sourceURL = Read-Host “Enter the Source Site Collection URL”


#Get the Target Site Collection URL

$targetURL = Read-Host “Enter the Destination Site Collection URL”


#Location for the backup file 

$backupPath = Read-Host “Enter the Backup File name & location (E.g. c:\temp\Source.bak)”


Try

{

  #Set the Error Action

  $ErrorActionPreference = "Stop"

 

 Write-Host "Backing up the Source Site Collection..."-ForegroundColor DarkGreen

 Backup-SPSite $sourceURL -Path $backupPath -force

 Write-Host "Backup Completed!`n"

 

 #Delete source Site Collection

 Write-Host "Deleting the Source Site Collection..."

 Remove-SPSite -Identity $sourceURL -Confirm:$false

 Write-Host "Source Site Deleted!`n"

 

 #Restore Site Collection to new URL

 Write-Host "Restoring to Target Site Collection..."

 Restore-SPSite $targetURL -Path $backupPath -Confirm:$false

 Write-Host "Site Restored to Target!`n"

 

 #Remove backup files

 Remove-Item $backupPath

}

catch

{

 Write-Host "Operation Failed. Find the Error Message below:" -ForegroundColor Red

 Write-Host $_.Exception.Message -ForegroundColor Red

}

finally

{

 #Reset the Error Action to Default

 $ErrorActionPreference = "Continue"

}

 

write-host "Process Completed!"
