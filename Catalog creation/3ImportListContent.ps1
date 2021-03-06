#This script will do the following:

#  - Read input parameters from the script '1InputParameters'
#  - Import content to a SharePoint list from a .cvs file
#  - If specified, deletes old list content before importing content from the .csv file

# ******************************************* #


# Get location of the script folder
function Get-ScriptDirectory 
{ 
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value 
    Split-Path $Invocation.MyCommand.Path 
} 

# Load up our common functions 
$commons = Join-Path (Get-ScriptDirectory) "1InputParameters.ps1"
. $commons


if ($productCatalogSiteCollectionURL -eq "") {
    Write-Host "Enter the URL of the Site Collection, e.g. http://www.hostname.com/sites/catalog " 
    $productCatalogSiteCollectionURL = Read-Host "URL "    
}

$Delete = Read-Host "Delete content of list (default :N) "
if ($Delete -eq "") {
    $Delete = "N"
}

$spWeb   = Get-SPWeb $productCatalogSiteCollectionURL
$spList  = $spWeb.getlist($productCatalogSiteCollectionURL + "/Lists/Products")

#read & update product catalog with pointer to Term set
if ($Delete.ToUpper() -eq "Y")
{
    $listItems = $spList.GetItems() 
    $cnt       = $listItems.Count  
    for ($i = 0; $i -lt $cnt; $i++)
    {
        $listItems.Delete(0)   # NOTE, use index = 0 to always delete from top of list
        $p = [math]::Ceiling(($i/$cnt) * 100)
        write-progress -activity "Delete content of $spList progress" -status "$p% Complete:" -percentcomplete $p;
    }
}

if (!$CatalogInpFile.contains(":\"))
{
    $CatalogInpFile = Join-Path (Get-ScriptDirectory) $CatalogInpFile
}

# Import CVS file
$data     = (Get-Content $CatalogInpFile)
$collName = [regex]::Split($data[0], "\t")
$label    = new-object object[] $collName.Count 

#adding fields to the list:
for ($i = 0; $i -lt $collName.Count; $i++)
{
    $elem      = $collName[$i].split(":")
    $label[$i] = $elem[$elem.length-1]
}

$cnt = $data.Count    
for ($i = 1; $i -lt $cnt; $i++)
{
    $value = [regex]::Split($data[$i], "\t")
    $list  = $spList.additem()
    for ($j = 0; $j -lt $value.Count; $j++)
    {
        $list[$label[$j]] = $value[$j]
    }
    $list.ModerationInformation.Status = [Microsoft.SharePoint.SPModerationStatusType]::Approved
    try {
        $list.update() 
    } catch {
        write-host "ERROR on input data: $value[$j]"
    }

    $p = [math]::Ceiling(($i/$cnt) * 100)
    write-progress -activity "Prod Catalog import progress" -status "Added record $i, $p% Complete:" -percentcomplete $p;
}