#Install the Microsoft Graph SDK PowerShell Module
#Microsoft.Graph is a meta module and it will pull in a whole set of other modules that provides access to different items within Microsoft Graph (Microsoft.Graph.Teams,Microsoft.Graph.Users)
Install-Module -Name Microsoft.Graph

#Get Command Count from Module
$Commands = Get-Command -Module Microsoft.Graph*
$Commands.Count

#View which Graph API the SDK will use
Get-MgProfile

#Change to the Beta API
Select-MgProfile -Name "Beta"

#Change to the Beta API
Select-MgProfile -Name "v1.0"

#Connect to Microsoft Graph (By default it uses Device Code Flow)
#Each API in the Microsoft Graph is protected by one or more permission scopes. Graph Api Reference (aka.ms/graphapiref) can help you determine the permission necessary for the call
Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All"

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
$Me = Get-MgUser -Filter "displayName eq 'Bradley Wyatt'"

#Query Parameters
Get-MgUser -UserId $Me.Id -Property DisplayName, Mail

#Add permissions to create a user
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

#Create a new user in my environment
$NewUserInfo = @{
  DisplayName = "Pauly PowerShell"
  MailNickName      = "Pauly.PowerShell"
  UserPrincipalName = "Pauly.PowerShell@thelazyadministrator.com"
  PasswordProfile = @{
    "forceChangePasswordNextSignIn"        = true
    "forceChangePasswordNextSignInWithMfa" = false
    "password"                             = "TemporaryP@ssword!"
  }
}
New-MgUser -AccountEnabled @NewUserInfo

#Get Permissions 
Connect-MgGraph -Scopes "Group.ReadWrite.All","Team.ReadBasic.All","TeamMember.ReadWrite.All"

#Create a team for PowerShell Summit
New-MgTeam -DisplayName "PowerShell Summit" -Description "PS Summit Team" -AdditionalProperties @{"template@odata.bind"="https://graph.microsoft.com/beta/teamsTemplates('standard')"}

#Get my new Team by looking up the Group
$Team = Get-MgGroup -Filter "displayName eq 'PowerShell Summit'" 
$Team

#Add me as a Team Owner
New-MgTeamMember -Id $Me.Id -TeamId $Team.Id -Roles "Owner"  -AdditionalProperties @{ 
                                                                    "@odata.type" = "#microsoft.graph.aadUserConversationMember"; 
                                                                    "user@odata.bind" = "https://graph.microsoft.com/v1.0/users/" + $me.Id
                                                                    }

#Sends a welcome message to the newly created Team
$PrimaryChannel = Get-MgTeamPrimaryChannel -TeamId $Team.Id
$PrimaryChannel
New-MgTeamChannelMessage -TeamId $Team.Id -ChannelId $PrimaryChannel.Id -Body @{Content = "Welcome to Teams!"}

# Create an web app with implicit auth
$NewUAzureApp = @{
  DisplayName = "PSSummit"
  Web      = @{ 
    RedirectUris = "https://localhost:3000/"
    ImplicitGrantSettings = @{ 
      EnableAccessTokenIssuance = $true
      EnableIdTokenIssuance = $true; 
    } 
  }
}
#New is doing a POST method
New-MgApplication @NewUAzureApp

#Get newly created Azure AD Application
$AzureApp = Get-MgApplication -Filter "displayName eq 'PSSummit'"

$AppSecret = Add-MgApplicationPassword -ApplicationId $AzureApp.Id
$AppSecret

#Add an application permission, Sites.Read.All, Directory.ReadWrite.All, Files.ReadWrite.All | 00000003-0000-0000-c000-000000000000 is the Id for the Graph API
#List of common Microsoft Resource IDs can be found here: https://www.shawntabrizi.com/aad/common-microsoft-resources-azure-active-directory/
#Can get list of permission Ids from Azure CLI - az ad sp show --id 00000003-0000-0000-c000-000000000000
#Update is doing a PATCH method
Update-MgApplication -ApplicationId $AzureApp.Id -RequiredResourceAccess @{ ResourceAppId = "00000003-0000-0000-c000-000000000000"
ResourceAccess = @(
        @{ 
            Id = "332a536c-c7ef-4017-ab91-336970924f0d"
            Type = "Role"
         };
        @{ 
          Id = "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
          Type = "Role"
        };
        @{ 
          Id = "75359482-378d-4052-8f01-80520e7db3cd"
          Type = "Role"
        }
     )
}
#Type would be Scope for delegated permission

#Need to go into the portal and grant admin consent, Also allow public client flows

#Disconnect from Microsoft Graph
Disconnect-MgGraph