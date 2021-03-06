#This script will do the following:

#  - Read input parameters from the script '1InputParameters'
#  - Connect each item in the SharePoint list with the correct term based on the value from the custom property 'ItemCategoryNumber'. 
#The correct term name will be added to the site column 'Item Category'

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


# the address of the term store
$termSetName     = "Product Hierarchy"
$SpSite          = Get-SPSite $productCatalogSiteCollectionURL
$taxonomySession = Get-SPTaxonomySession -Site $SpSite

$termStore       = $taxonomySession.DefaultSiteCollectionTermStore
$termStoreName   = "Site Collection - " + $productCatalogSiteCollectionURL.Replace("http://","").Replace("/","-").Replace(":","-")
$termStoreGroup  = $termStore.groups[$termStoreName]
$termSetName     = "Product Hierarchy"
$termSet         = $termStoreGroup.TermSets[$termSetName]

#read & update product catalog with pointer to Term set
$spWeb     = Get-SPWeb $productCatalogSiteCollectionURL
$spList    = $spWeb.getlist($productCatalogSiteCollectionURL + "/Lists/Products")

$listItems = $spList.GetItems() 

$cnt = $listItems.Count    
$i   = 0
foreach($item in $listItems)
{
    $i = $i + 1
    #Cast to SPListItem to avoid ambiguous overload error
    $spItem = [Microsoft.SharePoint.SPListItem]$item;
    $value  = $spItem.GetFormattedValue("ItemCategoryNumber")

    #Get the taxonomy field for the list item
    $taxField = [Microsoft.SharePoint.Taxonomy.TaxonomyField]$spItem.Fields["Item Category"]
    $terms    = $termSet.GetTermsWithCustomProperty("ItemCategoryNumber", $value, 0)

    if ($terms.Count -gt 0)
    {
        #Set the field's value using the term
        $taxField.SetFieldValue($spItem,$terms[0])
        $spItem.ModerationInformation.Status = [Microsoft.SharePoint.SPModerationStatusType]::Approved
        $spItem.Update()
    }
    $p = [math]::Ceiling(($i/$cnt) * 100)

    write-progress -activity "Prod Catalog & Term store sync progress" -status "$p% Complete:" -percentcomplete $p;
}