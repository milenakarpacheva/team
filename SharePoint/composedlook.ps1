Add-PSSnapin microsoft.sharepoint.powershell
$site = Get-SPsite http://sport.milena.k 
foreach ($web in $site.AllWebs)
{
$web.ApplyTheme("/_catalogs/theme/15/Palette005.spcolor", "/_catalogs/theme/15/fontscheme003.spfont", "/_layouts/15/images/image_bg005.jpg", $false)
$web.Dispose()
$site.Dispose()
}
