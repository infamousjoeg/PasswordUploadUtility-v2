# Password Upload Utility v2

[![CyberArk Ready](https://img.shields.io/badge/CyberArk-ready-blue.svg)](https://www.cyberark.com)[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://opensource.org/licenses/mit-license.php)[![GitHub forks](https://img.shields.io/github/forks/badges/shields.svg?style=social&label=Fork)](https://github.com/infamousjoeg/PasswordUploadUtility-v2/fork)[![GitHub stars](https://img.shields.io/github/stars/badges/shields.svg?style=social&label=Star)](https://github.com/infamousjoeg/PasswordUploadUtility-v2)[![GitHub watchers](https://img.shields.io/github/watchers/badges/shields.svg?style=social&label=Watch)](https://github.com/infamousjoeg/PasswordUploadUtility-v2/subscription)[![GitHub followers](https://img.shields.io/github/followers/espadrine.svg?style=social&label=Follow)](https://github.com/infamousjoeg)

Updated Password Upload Utility utilizing the REST API instead of an outdated and restricted version of PACLI.

## WELCOME CYBERARK IMPACT 2017 ATTENDEES!

Thank you for attending the **REST for the Rest of Us** breakout session!

## Usage

Download the ZIP file or ```git clone``` to a directory.

Open _passwords.csv_ and begin adding your account information.  Acceptable values for DisableAutoMgmt are yes or true.  Anything else will be considered a no.

Start > Run ```powershell```

```cd``` to the directory _PasswordUploadUtility-v2.ps1_ is located.

```.\PasswordUploadUtility-v2.ps1```

## PowerShell Function Examples

Available at [GitHub Gists](https://gist.github.com/infamousjoeg/9fd1ae60cdea88ac18dbbc49cf2bfe34)

```powershell
# REST API PowerShell Functions List
# Last Updated:  6/21/2017
#
# Be sure to set $PVWA_URL to be global like: $Global:PVWA_URL="https://pvwa.cyberark.local"
# before calling any functions.
#
# Before each function are three (3) # and the RESTful Method it is an example of.
# Any of those functions can be copied and used as a template for other functions
# to be created that are not listed here.  If you want to add PASREST-AddAccount,
# you would copy a POST example below and modify accordingly.  But don't do that,
# I've already done that and just haven't updated this yet.

### This function is an example of POST
function PASREST-Logon {

    # Declaration
    $webServicesLogon = "$PVWA_URL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon"

    # Authentication
    $bodyParams = @{username = "Svc_CyberArkAPI"; password = "Cyberark1"} | ConvertTo-JSON

    # Execution
    try {
        $logonResult = Invoke-RestMethod -Uri $webServicesLogon -Method POST -ContentType "application/json" -Body $bodyParams -ErrorVariable logonResultErr
        Return $logonResult.CyberArkLogonResult
    }
    catch {
        Write-Host "StatusCode: " $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription: " $_.Exception.Response.StatusDescription
        Write-Host "Response: " $_.Exception.Message
        Return $false
    }
}

### This function is an example of POST
function PASREST-Logoff ([string]$Authorization) {

    # Declaration
    $webServicesLogoff = "$PVWA_URL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logoff"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$Authorization)

    # Execution
    try {
        $logoffResult = Invoke-RestMethod -Uri $webServicesLogoff -Method POST -ContentType "application/json" -Header $headerParams -ErrorVariable logoffResultErr
        Return $true
    }
    catch {
        Write-Host "StatusCode: " $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription: " $_.Exception.Response.StatusDescription
        Write-Host "Response: " $_.Exception.Message
        Return $false
    }
}

### This function is an example of GET
function PASREST-GetAccount ([string]$Authorization) {

    # Declaration
    $webServicesGA = "$PVWA_URL/PasswordVault/WebServices/PIMServices.svc/Accounts?Keywords=$Keywords&Safe=$Safe"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$sessionID)

    # Execution
    try {
        $getAccountResult = Invoke-RestMethod -Uri $webServicesGA -Method GET -ContentType "application/json" -Headers $headerParams -ErrorVariable getAccountResultErr
        return $getAccountResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

### This function is an example of DELETE
function PASREST-DeleteAccount ([string]$Authorization) {

    # Declaration
    $webServicesDA = "$PVWA_URL/PasswordVault/WebServices/PIMServices.svc/Accounts/$AccountID"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$sessionID)

    # Execution
    try {
        $delAccountResult = Invoke-RestMethod -Uri $webServicesDA -Method DELETE -ContentType "application/json" -Headers $headerParams -ErrorVariable delAccountResultErr
        return $delAccountResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

### This function is an example of GET
function PASREST-ListSafes ([string]$Authorization) {

    # Declaration
    $webServicesSafes = "http://components.cyberark.local/PasswordVault/WebServices/PIMServices.svc/Safes"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$sessionID)

    # Execution
    try {
        $safesListResult = Invoke-RestMethod -Uri $webServicesSafes -Method GET -ContentType "application/json" -Headers $headerParams -ErrorVariable safesListResultErr
        return $safesListResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

### This function is an example of POST
function PASREST-AddUser ([string]$Authorization,[string]$userName,[string]$email,[string]$firstName,[string]$lastName) {

    # Declaration
    $webServicesAddUser = "$PVWA_URL/PasswordVault/WebServices/PIMServices.svc/Users"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$sessionID)
    $bodyParams = @{username = $userName; initialPassword = "Cyberark1"; email = $email;`
    firstName = $firstName; lastName = $lastName; changePasswordOnTheNextLogon = $true; userTypeName = "EPVUser"} | ConvertTo-JSON

    # Execution
    try {
        $addUserResult = Invoke-RestMethod -Uri $webServicesAddUser -Method POST -ContentType "application/json" -Header $headerParams -Body $bodyParams -ErrorVariable addUserResultErr
        return $addUserResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

### This function is an example of POST
function PASREST-AddUserToGroup ([string]$Authorization,[string]$userName,[string]$groupName) {

    # Declaration
    $webServicesAUTG = "$PVWA_URL/PasswordVault/WebServices/PIMServices.svc/Groups/$groupName/Users"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$sessionID)
    $bodyParams = @{UserName = "TestUser"} | ConvertTo-JSON

    # Execution
    try {
        $autgResult = Invoke-RestMethod -Uri $webServicesAUTG -Method POST -ContentType "application/json" -Header $headerParams -Body $bodyParams -ErrorVariable logonResultErr
        return $autgResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}
```

## TODO

* Add Bulk Change Method
* Add Additional Properties for non-Windows accounts
