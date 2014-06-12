function ActivateSCFeatures(
[string]$spSiteCollection
) 
{

    Add-PSSnapin Microsoft.SharePoint.PowerShell
    If($spSiteCollection.Length -eq '0')
    {
        While ($spSiteCollection -eq '' -or (Get-SPSite -Identity $spSiteCollection) -eq $null)
        {
            Write-Host "Choose a site:"
            $spSiteCollection = Read-Host
        }
    }
   $siteFeatures = Get-SPFeature | Where-Object {$_.Scope -eq 'Site'} 
if ($siteFeatures -ne $null)
 {
   foreach ($feature in $siteFeatures)
   {
      if ((Get-SPFeature -Site $spSiteCollection | Where-Object {$_.Hidden -eq $false} | Where-Object {$_.Id -eq $feature.id}) -ne $null ) 
      {
         # Active feature
       
        Disable-SPFeature -Url $spSiteCollection -Identity $feature.id -Confirm:$false -ErrorAction Ignore | Where-Object (({$_.Id-eq $feature.id}) -ne $null) | foreach-Object {$_.Hidden -eq $false}
        
        Enable-SPFeature -Url $spSiteCollection -Identity $feature.id -Confirm:$false -ErrorAction Ignore | Where-Object (({$_.Id-eq $feature.id}) -eq $null) | foreach-Object {$_.Hidden -eq $false}
        Write-Host "$($feature.Scope) feature $($feature.DisplayName) is reactivated" -ForeGroundColor Cyan  
         }
         

}
}
}