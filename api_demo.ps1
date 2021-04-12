# Application (client) ID, tenant Name and secret
$clientId = "eb352dbc-850e-4de9-aa3e-c5440d6040a4"
$tenantName = "bwya77.onmicrosoft.com"
$clientSecret = "vv6LgJFX.44_5_9l2wc9AZE5iscCCrCg_~"


$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 

$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
$TokenResponse

#Inspect the token using JWTDetails
Get-JWTDetails($TokenResponse.access_token)


$apiUrl = 'https://graph.microsoft.com/v1.0/sites/'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$Sites = ($Data | select-object Value).Value
 
 
$Sites | Format-List