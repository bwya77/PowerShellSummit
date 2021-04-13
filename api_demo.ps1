# Application (client) ID, tenant Name and secret
$clientId = ""
$tenantName = "bwya77.onmicrosoft.com"
$clientSecret = ""


$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 

$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
$TokenResponse



#Inspect the token using JWTDetails
#JWTDetails PowerShell Module by Darren J Robinson, Microsoft MVP
#https://github.com/darrenjrobinson/JWTDetails
Get-JWTDetails($TokenResponse.access_token)



$request = @{
    Method      = "Get"
    Uri         = 'https://graph.microsoft.com/v1.0/sites/'
    ContentType = "application/json"
    Headers     = @{Authorization = "Bearer $($Tokenresponse.access_token)"}
}
$Data = Invoke-RestMethod @request
$Sites = ($Data | select-object Value).Value
$Sites | Format-List
$Sites.Count



#Get all users, similar to when we did it in the SDK
$request = @{
    Method      = "Get"
    Uri         = 'https://graph.microsoft.com/v1.0/users/'
    ContentType = "application/json"
    Headers     = @{Authorization = "Bearer $($Tokenresponse.access_token)"}
}
$Data = Invoke-RestMethod @request
$Users = ($Data | select-object Value).Value
$Users.Count



#Use a query parameter to get my account (#line 39 in sdk demo)
$request = @{
    Method      = "Get"
    Uri         = "https://graph.microsoft.com/v1.0/users/?`$filter=(displayName eq 'Bradley Wyatt')"
    ContentType = "application/json"
    Headers     = @{Authorization = "Bearer $($Tokenresponse.access_token)"}
}
$Data = Invoke-RestMethod @request
$Users = ($Data | select-object Value).Value
$Users.Count



#Use Batching to do multiple calls at once
$BatchBody = @"
{
  "requests": [
    {
      "id": "1",
      "method": "GET",
      "url": "/users"
    },
    {
      "id": "2",
      "method": "GET",
      "url": "/Groups"
    },
  ]
}
"@ 
$request = @{
    Method      = "Post"
    Uri         = "https://graph.microsoft.com/v1.0/`$batch"
    ContentType = "application/json"
    Headers     = @{Authorization = "Bearer $($Tokenresponse.access_token)"}
    Body        = $BatchBody
}
$BatchRes = Invoke-RestMethod @request
#Show all our Users
$users = $BatchRes.responses | Where-Object { $_.id -eq 1 }
$users.body.value | Select-Object displayName
#Show all our Groups
$Groups = $BatchRes.responses | Where-Object { $_.id -eq 2 }
$Groups.body.value | Select-Object displayName




#Use PATCH to update a file in OneDrive, Requires Files.ReadWrite.All

#See the file is not present
$request = @{
    Method      = "Get"
    Uri         = 'https://graph.microsoft.com/v1.0/users/brad@thelazyadministrator.com/drive/items/root:/UploadDummy/File01.rtf'
    ContentType = "application/json"
    Headers     = @{Authorization = "Bearer $($Tokenresponse.access_token)"}
}
$firstFile = Invoke-RestMethod @request

#Updating the file
$newfileName = @"
{
  "name": "new-file-name.docx"
}
"@
$request = @{
    Method      = "Patch"
    Uri         = "https://graph.microsoft.com/v1.0/users/brad@thelazyadministrator.com/drive/items/$($firstFile.id)"
    ContentType = "application/json"
    Headers     = @{Authorization = "Bearer $($Tokenresponse.access_token)"}
    Body        = $newfileName
}
Invoke-RestMethod @request



#Refresh Token
#must make sure your application in Authentication allows public client flows
$DeviceCodeRequestParams = @{
    Method = 'POST'
    Uri    = "https://login.microsoftonline.com/6438b2c9-54e9-4fce-9851-f00c24b5dc1f/oauth2/devicecode"
    Body   = @{
        client_id = $ClientId
        resource  = "https://graph.microsoft.com/"
    }
}

$DeviceCodeRequest = Invoke-RestMethod @DeviceCodeRequestParams
Write-Host $DeviceCodeRequest.message -ForegroundColor Yellow

$TokenRequestParams = @{
    Method = 'POST'
    Uri    = "https://login.microsoftonline.com/6438b2c9-54e9-4fce-9851-f00c24b5dc1f/oauth2/token"
    Body   = @{
        grant_type = "device_code"
        code       = $DeviceCodeRequest.device_code
        client_id  = $ClientId
    }
}
$TokenRequest = Invoke-RestMethod @TokenRequestParams
#View the refresh token
$TokenRequest.refresh_token
#View when the token expires
Get-JWTDetails($TokenRequest.access_token)
#Using the refresh token, get a new access token
$request = @{
    Method      = "Post"
    Uri         = "https://login.microsoftonline.com/6438b2c9-54e9-4fce-9851-f00c24b5dc1f/oauth2/v2.0/token"
    Body        = @{
        Grant_Type    = "Refresh_Token"
        client_Id     = $clientID
        Refresh_TOken = $TokenRequest.refresh_token
    }
}

$TokReqRes = Invoke-RestMethod @request
#View new expiry date time
Get-JWTDetails($TokReqRes.access_token)
