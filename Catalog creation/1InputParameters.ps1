#This script will do the following:

#  - Input the parameters needed for running other PowerShell scrips for creating SharePoint list content

# ******************************************* #


#Modify this script by adding the following:
#	- URL your Product Catalog Site Collection, e.g. http://www.contoso.com/sites/ProductCatalog"
$productCatalogSiteCollectionURL = "http://sport.milena.k/sites/catalog"   

#	- Path and file name of the file containing the content to be imported into the SharePoint list
$CatalogInpFile         = "C:\Users\Administrator\Desktop\content.txt"

#	- Path and file name of the file containing the taxonomy to be imported
$TaxonomyInpFile            = "C:\Users\Administrator\Desktop\Book1.txt"

#	 - List of site columns that should be added to the your list. Site columns will automatically become managed properties after crawling
$columnlist = @{}
$columnlist.("Color") = "Text"



# ******************************************* #


# Common code:
# All scripts need to initiate SharePoint Snapin if not done
$spInstalled = Get-PSSnapin | Select-String Sharepoint
if (!$spInstalled)
{
    Add-PSSnapin Microsoft.Sharepoint.PowerShell
}

