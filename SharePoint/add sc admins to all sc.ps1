# set site collection owner for all sites
Add-PSSnapin Microsoft.SharePoint.PowerShell
 
# Set Account list
$AccountList = @("Milena\aliciat")
 
#sites at the IIS level:
$IISSites = Get-SPWebApplication
Foreach($oneIISSite in $IISSites)
{
   foreach ($SharepointSiteCollection in $oneIISSite.Sites)
   {
      write-host $SharepointSiteCollection.url -ForegroundColor Cyan
      $spweb = Get-SPWeb $SharepointSiteCollection.url
 
      foreach ($Account in $AccountList)
      {
         Write-host "Looking to see if User "$account" is a member on" $SharepointSiteCollection.url -foregroundcolor White
         $user = Get-SPUSER -identity $Account -web $SharepointSiteCollection.url -ErrorAction SilentlyContinue 
         if ($user -eq $null)
         {
            #if the user did NOT exist, will be added.
            $SPWeb.ALLUsers.ADD($Account, "", "", "Added by AdminScript")
            $user = Get-SPUSER -identity $Account -web $SharepointSiteCollection.url
            Write-host "Added user $Account to URL $SPWeb" -Foregroundcolor Magenta
         }
         else
         {
            Write-host "user $Account was already in URL" $SPWeb -Foregroundcolor DarkGreen
         }
         if ($user.IsSiteAdmin -ne $true)
         {
            $user.IsSiteAdmin = $true
            $user.Update()
            Write-host "$account has been made an admin on $SPWeb" -Foregroundcolor Magenta
         }
         else
         { 
         Write-host "$account was already an admin on $SPWeb" -Foregroundcolor DarkGreen
         }
     }
     $SharePointSiteCollection.Dispose()
}
}
