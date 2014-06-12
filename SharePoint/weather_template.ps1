#Requires -version 2.0Add-PSSnapin microsoft.sharepoint.powershellFunction Get-Weather { Param(  [Parameter(Mandatory=$true)]  [string]$city,  [Parameter(Mandatory=$true)]  [string]$country )#end param $URI = "http://www.webservicex.net/globalweather.asmx?wsdl" $Proxy = New-WebServiceProxy -uri $URI -namespace WebServiceProxy $Proxy.GetWeather($city,$country)} #end Get-Weather[xml]$xml = Get-Weather -city "sofia" -country "Bulgaria"[string]$a = $xml.CurrentWeather.SkyConditionsswitch -Regex ([string]$a){"mostly cloudy"{$site = Get-SPsite http://sales.milena.k$web = Get-SPWeb http://sales.milena.k$web.ApplyTheme("/_catalogs/theme/15/Palette004.spcolor", "/_catalogs/theme/15/fontscheme002.spfont", "/_catalogs/theme/Themed/9C9F7468/8a095680-9282-4cfb-8d1e-3e468cbb05abbkimage-922B1D8A.themedjpg?ctag", $false)
$web.Dispose()
$site.Dispose()}

"sunny"{$site = Get-SPsite http://sales.milena.k$web = Get-SPWeb http://sales.milena.k$web.ApplyTheme("/_catalogs/theme/15/Palette004.spcolor", "/_catalogs/theme/15/fontscheme002.spfont", "/_catalogs/theme/Themed/8E2B54F/cd6bd7da-22bd-482d-9b56-e65f6e16d680bkimage-B7850508.themedjpg?ctag", $false)
$web.Dispose()
$site.Dispose()}

"clear"{$site = Get-SPsite http://sales.milena.k$web = Get-SPWeb http://sales.milena.k$web.ApplyTheme("/_catalogs/theme/15/Palette004.spcolor", "/_catalogs/theme/15/fontscheme002.spfont", "/_catalogs/theme/Themed/384D6626/90ab76e8-ac0c-4317-a75f-46b536c97169bkimage-8302FF4D.themedjpg?ctag", $false)
$web.Dispose()
$site.Dispose()}

"rainy"{$site = Get-SPsite http://sales.milena.k$web = Get-SPWeb http://sales.milena.k$web.ApplyTheme("/_catalogs/theme/15/Palette004.spcolor", "/_catalogs/theme/15/fontscheme002.spfont", "/_catalogs/theme/Themed/B1EB1A41/f2958066-562e-4d34-8fd9-bc19d882d7a8bkimage-700A9F82.themedjpg?ctag", $false)
$web.Dispose()
$site.Dispose()}

"partly cloudy"{$site = Get-SPsite http://sales.milena.k$web = Get-SPWeb http://sales.milena.k$web.ApplyTheme("/_catalogs/theme/15/Palette004.spcolor", "/_catalogs/theme/15/fontscheme002.spfont", "/_catalogs/theme/Themed/E7046BDF/b612fe11-fdf2-4d88-887b-40a6ae884750bkimage-9137727.themedjpg?ctag", $false)
$web.Dispose()
$site.Dispose()}

"snow"{$site = Get-SPsite http://sales.milena.k$web = Get-SPWeb http://sales.milena.k$web.ApplyTheme("/_catalogs/theme/15/Palette004.spcolor", "/_catalogs/theme/15/fontscheme002.spfont", "/_catalogs/theme/Themed/snow/769f2c40-097b-4c51-ab31-0bcfeef350bfbkimage-27544183.themedjpg?ctag", $false)
$web.Dispose()
$site.Dispose()}

"overcast"{$site = Get-SPsite http://sales.milena.k$web = Get-SPWeb http://sales.milena.k$web.ApplyTheme("/_catalogs/theme/15/Palette004.spcolor", "/_catalogs/theme/15/fontscheme002.spfont", "/_catalogs/theme/Themed/58A084AB/778449d7-bffc-4484-9a73-796798e8a2bebkimage-F3F6B40E.themedjpg?ctag", $false)
$web.Dispose()
$site.Dispose()}
}
