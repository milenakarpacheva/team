<#
.SYNOPSIS
   Set SharePoint farm outgoing email address.
.DESCRIPTION
   Set SharePoint farm outgoing email address.
.PARAMETER SMTPServer
   Specify outbound SMTP server hostname.
.EXAMPLE
   Set-SPFarmOutgoingEmail -SMTPServer smtp.contoso.com -FromAddress 'sharepoint@contoso.com' -ReplyToAddress 'do-not-reply@contoso.com'
   Will set farm outgoing email address to 'sharepoint@contoso.com' and reply to address 'do-not-reply@contoso.com' . Will configure SharePoint farm to use server smtp.contoso.com for smtp relay host.
.INPUTS
.OUTPUTS
.NOTES
.LINK
#>

function Set-SPFarmOutgoingEmail {
	[CmdLetBinding()]
	param (
		[string]$SMTPServer,
		[string]$FromAddress,
		[string]$ReplyToAddress,
		[string]$charset = '65001'
	)
	begin {
		Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
	}
	process {
		$CAWebApp = Get-SPWebApplication -IncludeCentralAdministration | Where { $_.IsAdministrationWebApplication }
		$CAWebApp.UpdateMailSettings($SMTPServer, $FromAddress, $ReplyToAddress, $charset)
	}
}
