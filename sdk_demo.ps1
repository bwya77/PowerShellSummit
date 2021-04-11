#Install the Microsoft Graph SDK PowerShell Module
Install-Module -Name Microsoft.Graph

#Get Command Count from Module
$Commands = Get-Command -Module Microsoft.Graph*
$Commands.Count

#View which Graph API the SDK will use
Get-MgProfile

#Change to the Beta API
Select-MgProfile -Name "Beta"

#Connect to Microsoft Graph (By default it uses Device Code Flow)
Connect-MgGraph -Scopes "User.Read.All"

#List all of our users in the our Azure AD Directory
Get-MgUser -All

#Filter Parameter
<#
Support for $filter operators varies across Microsoft Graph APIs. The following logical operators are generally supported:

equals eq / not equals ne
less than lt / greater than gt
less than or equal to le / greater than or equal to ge
and and / or or
in in
Negation not
lambda operator any any
lambda operator all all
Starts with startsWith
Ends with endsWith
#>
Get-MgUser -Filter "displayName eq 'Bradley Wyatt'"

#Get User Info
Get-MgUser -UserId "5bcffade-2afd-48a2-8096-390a9090555c"

#Query Parameters
Get-MgUser -UserId "5bcffade-2afd-48a2-8096-390a9090555c" -Property DisplayName, Mail

