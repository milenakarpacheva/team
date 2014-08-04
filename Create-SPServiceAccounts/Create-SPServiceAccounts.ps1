<#
.SYNOPSIS
   Create SharePoint 2013 and SQL Server service accounts.
.DESCRIPTION
   Create SharePoint 2013 and SQL Server service accounts. Accounts will be enabled with 'Password Never expires' attribute. Service account data is defined in Input files. Supported formats for input files are XML,CSV,Excel(.xlsx).
   Script can be launched on a target Domain Controller or accounts can be created remotely by running the script in Remote mode by supplying RemoteDC and remote credentials.
   Remote DC can be supplied by IP or computer name. The script can run from computer in the target domain or not. To use Excel file you will need Excel office application installed on the computer where the script is running from.
   In remote mode the script should run with elevated (as Administrator) privileges
   
   To use the script remotely you need to configure PSRemoting first on the local and remote computers!
   
   A default password can be supplied and it will override the passwords from the input file.
   
   Organisation Unit can be supplied, if the OU exists somewhere in the domain the accounts will be created in it, if not the script will create OU with the provided name in the root container of the domain.
   
   Script Developed by: Ivan Yankulov <SharePoint Administrator in BulPros Consulting>
   CONTACT ME: 
   http://spyankulov.blogspot.com

.OUTPUTS
The script will inform you for account that is created. If there is some error a custom message in red color will be displayed and the message of the exception that has occurred.
.EXAMPLE
 .\Create-SPServiceAccounts.ps1 -Local -InputPath "C:\Create-SPServiceAccounts\InputCSV.csv" -OUName 'ServiceAccounts'
 Description
 -----------
 This will create the service accounts from input CSV file. The script run on the DC where the account will be created. The passwords for the accounts are defined in the input file.
 
.EXAMPLE
 .\Create-SPServiceAccounts.ps1 -InputPath .\InputXML.xml -OUName 'ServiceAccounts' -Remote -RemoteDC '192.168.1.170' -RemoteUser 'Contoso\Domain_Administrator' -RemotePass 'demo!234' -Password 'demo!234'
 
 Description
 -----------
This will create the service account on RemoteDC by IP. The input file is XML. A Password parameter is supplied and it will override the passwords from the input. Account for the remote session is 'Contoso\Domain_Administrator'.

.EXAMPLE
 .\Create-SPServiceAccounts.ps1 -InputPath 'C:\Create-SPServiceAccounts\InputExcel.xlsx' -OUName 'ServiceAccounts' -Remote -RemoteDC 'dc.contoso.net' -RemoteUser 'Contoso\Domain_Administrator' -RemotePass 'demo!234'
 
 Description
 -----------
This will create the service accounts from input Excel file. The script is running from computer located in the target domain. The password for the accounts are defined in the input file. Account for the remote session is 'Contoso\Domain Administrator'.

 
#>

[CmdletBinding(DefaultParameterSetName="PSet1")]
Param(
	[parameter(Mandatory=$false,ParameterSetName="PSet1")]
	[switch]$Local = $false,
	[parameter(Mandatory=$true,Position=0)]
	[string]$InputPath,
	[parameter(Mandatory=$false)]
	[string]$Password,
	[parameter(Mandatory=$true)]
	[string]$OUName,
	[parameter(Mandatory=$true,ParameterSetName="PSet2")]
	[switch]$Remote = $false,
	[parameter(Mandatory=$true,ParameterSetName="PSet2")]
	[string]$RemoteDC,
	[parameter(Mandatory=$true,ParameterSetName="PSet2")]
	[string]$RemoteUser,
	[parameter(Mandatory=$true,ParameterSetName="PSet2")]
	[string]$RemotePass
)
## Function Region
function Test-AccountData{
[CmdletBinding()]
Param (
	[parameter(Mandatory=$true)]
	[System.Collections.Hashtable]$Data
)
If((($Data['AccountName']).ToString()).Length -gt 20){
	Write-Host "AccountName lenght of `"$($Data['AccountName'])`" is more then 20 symbols found. It will NOT be created!" -ForegroundColor Red
	return $false
}
ElseIf (-NOT ($Data['Password'])){
	Write-Host "There is no password or default password supplied for Account `"$($Data['AccountName'])`".It will NOT be created!" -ForegroundColor Red
	return $false
}
ElseIf ((($Data['AccountName']).ToString()).Length -lt 1){
	return $false
}
Else{
	return $true
}
}
function Read-Excel{
 [CmdletBinding()]
Param (
	[parameter(Mandatory=$true)]
	[string]$Path,
	[parameter(Mandatory=$false)]
	[string]$DefaultPass
)
$objExcel = New-Object -ComObject Excel.Application
$objExcel.Visible = $false
$WorkBook = $objExcel.Workbooks.Open($Path)
$WorkSheet = $WorkBook.sheets | Where {$_.Index -eq '1'}
$intRowMax = ($WorkSheet.UsedRange.Rows).count
$OutputAll = @()
for($intRow = 2 ; $intRow -le $intRowMax ; $intRow++)
{
	$Output = @{
		"AccountName" = $WorkSheet.Range("A$($intRow)").Text
		"Description" = $WorkSheet.Range("B$($intRow)").Text
		"Password" = $WorkSheet.Range("C$($intRow )").Text
	}
	If($DefaultPass){
		$Output['Password'] = $DefaultPass
	}
	If (Test-AccountData -Data $Output){
		$OutputAll += $Output
	}
}
Write-Output $OutputAll
$objExcel.Quit()
(Get-Process -name excel -ErrorAction SilentlyContinue | Sort-Object StartTime)[-1] | Stop-Process -ErrorAction SilentlyContinue
Remove-Variable objExcel
}
function Read-XML{
 [CmdletBinding()]
Param (
	[parameter(Mandatory=$true)]
	[string]$Path,
	[parameter(Mandatory=$false)]
	[string]$DefaultPass
)
[xml]$xmlInput = Get-Content $Path
$OutputAll = @()
ForEach ($xElement in ($xmlInput.ServiceAccounts.Account))
{
	$Output = @{
		"AccountName" = $xElement.AccountName
		"Description" = $xElement.Description
		"Password" = $xElement.Password
	}
	If($DefaultPass){
		$Output['Password'] = $DefaultPass
	}
	If (Test-AccountData -Data $Output){
		$OutputAll += $Output
	}

}
Write-Output $OutputAll
}
function Read-CSV{
 [CmdletBinding()]
Param (
	[parameter(Mandatory=$true)]
	[string]$Path,
	[parameter(Mandatory=$false)]
	[string]$DefaultPass
)
$csvImput = Import-Csv -Path $Path
$OutputAll = @()
ForEach($row in $csvImput)
{
	$Output = @{
		"AccountName" = $row.AccountName
		"Description" = $row.Description
		"Password" = $row.Password
	}
	If($DefaultPass){
		$Output['Password'] = $DefaultPass
	}
	If (Test-AccountData -Data $Output){
		$OutputAll += $Output
	}

}
Write-Output $OutputAll
}
function Create-UsersLocal{
 [CmdletBinding()]
Param (
	[parameter(Mandatory=$true)]
	[System.Object[]]$Hash,
	[parameter(Mandatory=$true)]
	[string]$OUnit
)
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
$OUObject = Get-ADOrganizationalUnit -Filter 'Name -eq $OUnit' -ErrorAction SilentlyContinue
If(-NOT ($OUObject) ){
	Try{
		Write-Host "Creating OU with name `"$($OUnit)`" " -ForegroundColor Green
		$OUObject = New-ADOrganizationalUnit -Name $OUnit -ErrorAction Stop
	}
	Catch [System.Exception]{
		Write-Host "Unable to create OU with name `"$($OUnit)`", folowing exception occurred: $($_.Exception.Message)" -ForegroundColor Red
	}
}
Else{
	Write-Host "OU with name `"$($OUnit)`" already exists. DN = $($OUObject.DistinguishedName)" -ForegroundColor Green
}
$Path = (Get-ADOrganizationalUnit -Filter 'Name -eq $OUnit').DistinguishedName
ForEach ($uData in $Hash)
{
	$secPass = ConvertTo-SecureString -String $uData['Password'] -AsPlainText -Force
	Try{
		Write-Host "Creating Service Account `"$($uData['AccountName'])`"." -ForegroundColor Green
		New-ADUser -SamAccountName $uData['AccountName'] -Name $uData['AccountName'] -AccountPassword $secPass -Description $uData['Description'] -Path $Path -UserPrincipalName (($uData['AccountName']) + "@" + (Get-WmiObject -Class Win32_ComputerSystem -namespace "root\CIMV2").Domain) -DisplayName "Service Account" -Enabled:$true -PasswordNeverExpires:$true -ChangePasswordAtLogon:$false -ErrorAction Stop
	}
	Catch [System.Exception]{
		Write-Host "Unable to create Account with name `"$($uData['AccountName'])`", folowing exception occurred: $($_.Exception.Message)" -ForegroundColor Red
	}
}
}
function Check-IsIP{
 [CmdletBinding()]
Param(
	[parameter(Mandatory=$true)]
	[string]$String
)
$ipObject = [System.Net.IPAddress]::Parse($String)
$validate = [System.Net.IPAddress]::Tryparse($String,[ref]$ipObject)
If($validate){
	Write-Output $true
}
Else{
	Write-Output $false
}
}

function Create-UsersRemote{
 [CmdletBinding()]
param(
	[parameter(Mandatory=$true)]
	[System.Object[]]$Hash,
	[parameter(Mandatory=$true)]
	[string]$OUnit,
	[parameter(Mandatory=$true)]
	[string]$RemDC,
	[parameter(Mandatory=$true)]
	[string]$RemUser,
	[parameter(Mandatory=$true)]
	[string]$RemPass
)
$isIP = Check-IsIP -String $RemDC -ErrorAction SilentlyContinue
If($isIP){
[string]$trustedHostsOLD = (Get-Item "WSMan:\localhost\Client\TrustedHosts").Value
Set-Item "WSMan:\localhost\Client\TrustedHosts" -Value $RemDC -Force
}
$user = $RemUser
$pass = $RemPass
$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
$session = New-PSSession -ComputerName $RemDC -Credential $cred -Name 'ServiceAccountC' -ErrorAction SilentlyContinue
If(!($session)){
	Set-Item "WSMan:\localhost\Client\TrustedHosts" -Value $trustedHostsOLD -Force
	Throw "Unable to create remote session to the target `"$($RemDC)`". Check credentials, permissions or connectivity to `"$($RemDC)`""
}
Else{
	Try{
		Invoke-Command -Session $session -ScriptBlock ${function:Create-UsersLocal} -ArgumentList $Hash,$OUnit -ErrorAction Stop
	}
	Catch [System.Exception]{
		Write-Host "Unable to create create the Service Accounts, folowing exception occured: $($_.Exception.Message)" -ForegroundColor Red
	}
	Finally{
		Remove-PSSession -Name 'ServiceAccountC' -ErrorAction SilentlyContinue
		If($isIP){
			Set-Item "WSMan:\localhost\Client\TrustedHosts" -Value $trustedHostsOLD -Force -ErrorAction SilentlyContinue
			}
	}
}

}
## End function region
Try{
	$InputPath = (Resolve-Path $InputPath -ErrorAction Stop).ToString()
}
Catch [System.Exception]{
	Throw "Unable to resolve the InputPath, folowing exception occured: $($_.Exception.Message) !"
}
If (Test-Path -Path $InputPath){
	$inputFile = Get-Item $InputPath
}
Else{
	Throw "Unable to get the InputPath, folowing exception occured: $($_.Exception.Message) !"
}
If ($inputFile.Extension -eq ".csv"){
	$inputHash = Read-CSV -Path $InputPath -DefaultPass $Password
}
ElseIf ($inputFile.Extension -eq ".xml"){
	$inputHash = Read-XML -Path $InputPath -DefaultPass $Password
}
ElseIf ($inputFile.Extension -eq ".xlsx"){
	$inputHash = Read-Excel -Path $InputPath -DefaultPass $Password
}
Else{
	Throw "File Format `"$($inputFile.Extension)`" is not supported !!! "
}
switch ($PsCmdlet.ParameterSetName){
	"PSet1" { Create-UsersLocal -Hash $inputHash -OUnit $OUName ; break}
	"PSet2" { Create-UsersRemote -Hash $inputHash -OUnit $OUName -RemDC $RemoteDC -RemUser $RemoteUser -RemPass $RemotePass ; break}
}