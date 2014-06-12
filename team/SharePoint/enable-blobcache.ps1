Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
function Enable-SPBlobCache {

param(

    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
    [Microsoft.SharePoint.PowerShell.SPWebApplicationPipeBind]
    $WebApplication
)

	process {
	
		$WebApp = $WebApplication.Read()
		# SPWebConfigModification to enable BlobCache
		$configMod1 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification
		$configMod1.Path = "configuration/SharePoint/BlobCache" 
		$configMod1.Name = "enabled" 
		$configMod1.Sequence = 0
		$configMod1.Owner = "BlobCacheMod" 
		## SPWebConfigModificationType.EnsureChildNode -> 0
		## SPWebConfigModificationType.EnsureAttribute -> 1
		## SPWebConfigModificationType.EnsureSection -> 2
		$configMod1.Type = 1
		$configMod1.Value = "true" 
	
		# SPWebConfigModification to enable client-side Blob caching (max-age)
		$configMod2 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification
		$configMod2.Path = "configuration/SharePoint/BlobCache" 
		$configMod2.Name = "max-age" 
		$configMod2.Sequence = 0
		$configMod2.Owner = "BlobCacheMod" 
	
		## SPWebConfigModificationType.EnsureChildNode -> 0
		## SPWebConfigModificationType.EnsureAttribute -> 1
		## SPWebConfigModificationType.EnsureSection -> 2
	
		$configMod2.Type = 1
		$configMod2.Value = "86400" 
		
		
		# SPWebConfigurationModification to move blobstore location
		$configMod3 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification
		$configMod3.Path = "configuration/SharePoint/BlobCache" 		
		$configMod3.Name = "location"
		$configMod3.Sequence = 0
		$configMod3.Owner = "BlobCacheMod" 
		$configMod3.Type = 1
		$configMod3.Value = "C:\Blobcache\15"		
		
		
	
		# Add mods, update, and apply
	
		$WebApp.WebConfigModifications.Add( $configMod1 )
		$WebApp.WebConfigModifications.Add( $configMod2 )
		$WebApp.WebConfigModifications.Add( $configMod3 )
		$WebApp.Update()
		$WebApp.Parent.ApplyWebConfigModifications()
	
	}


} 

$wa = Get-SPWebApplication http://mysite.elabs.work
Enable-SPBlobCache $wa
