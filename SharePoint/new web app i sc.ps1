# This script will create new Web Application and then create a new Site Collection
#Gather the web application and site collection variables

$Name = “kickbox”

$Port = 80

$HostHeader = "kickbox.milena.k"

$AppPoolName = “kickboxAppPool”

$AppPoolAcct = “milena\SportGames”

$SiteName = “kickbox”

$SiteURL = “http://kickbox.milena.k”

$SiteOwner = “milena\Administrator”

$Template = “STS#”

# Create Web Application

function create_WebApp

{

New-SPWebApplication -Name $Name -HostHeader $HostHeader -Port $Port -ApplicationPool $AppPoolName -ApplicationPoolAccount $AppPoolAcct

}

# Create Site Collection

function create_SiteCollection

{

New-SPSite $SiteURL -OwnerAlias $SiteOwner -Template $Template

}

if (create_WebApp)

{

Write-Host $HostHeader

create_SiteCollection

}

else

{

Write-Host “Error”

}

if (create_SiteCollection)

{

Write-Host "success"

}
