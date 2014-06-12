function Test-F(
[string]$SourceUrl,
[string]$Target,
[string]$BackupPath
)
{

    Add-PSSnapin Microsoft.SharePoint.PowerShell
    If($SourceUrl.Length -eq '0')
    {
        While ($SourceUrl -eq '' -or (Get-SPSite -Identity $SourceUrl) -eq $null)
        {
            Write-Host "Give me valid site:"
            $SourceUrl = Read-Host
        }

    }
      If($Target.Length -eq '0')
    {
        While ($Target -eq '' -or $Target -eq '0')
        {
            Write-Host "Provide Target:"
            $Target = Read-Host
         } 

    }
    If($BackupPath.Length -eq '0')
    {
        While($BackupPath.Length -eq '0' -or $BackupPath -eq '')
        {
            Write-Host "choose backup file path:"
            $BackupPath = Read-Host
        }
    }


    

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

 Restore-SPSite $target -Path $backupPath -Confirm:$false

 Write-Host "Site Restored to Target!`n"

 Write-host "Process Completed!"
}