#Gather the web application and site collection variables

$Name = “SportGames Web App”

$URL = “http://Sportgames.milena.k”

$AppPoolName = “SportGamesAppPool"

$AppPoolAcc = “MILENA\SportGames"

$SiteName = “Sport Games”

$SiteURL = “http://Sportgames.milena.k”

$SiteOwner = “MILENA\Administrator”

# Create Web Application

function create_WebApp

{

New-SPWebApplication -Name $Name -URL $URL -ApplicationPool $AppPoolName -ApplicationPoolAccount $AppPoolAcc

}

# Create Site Collection

function create_SiteCollection

{

New-SPSite -URL $SiteURL -OwnerAlias $SiteOwner
}

