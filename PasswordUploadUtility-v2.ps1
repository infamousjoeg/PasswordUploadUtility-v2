#########################################################################
# Password Upload Utility v2
# 
# Description:  Updated Password Upload Utility utilizing the REST API
#               instead of an outdated and restricted version of PACLI
#
# Created by:   Joe Garcia, CISSP
#
# GitHub Repo:  https://github.com/infamousjoeg/PasswordUploadUtility-v2
# 
################## WELCOME TO CYBERARK IMPACT 2017! #####################
#
# TODO:         Add Bulk Change Method
#               Add Additional Properties for non-Windows accounts -- added by Joe Arida
#
# CHANGELOG: changed to use 2-factor RADIUS instead of LDAP. Updated functions to support Oracle DB and AD Domain accounts.
#    line 39: commented out as it was causing errors in my environment and I couldn't get it resolved. Can uncomment if desired for newer TLS.
#    line 59-60: commented out LDAP password
#    line 63-64: added 2-factor Radius auth
#    line 67: added useRadiusAuthentication = 'True' to leverage 2-factor instead of AD auth
#    line 108: added additional params to function
#    line 118-125: sends different parameters based off the attributes that are populated in the spreadsheet
#                    if both database and logondomain are populated in the same row then it will only send database due to order of if else statement. Could adjust if desired.
#    line 128: added to convert bodyParams to appropriate JSON syntax
#    line 131: added Write-Host $bodyParams to be used for debugging. Throws up the JSON on the screen to check syntax, uncomment when needed
#    line 177: commented out apiPassword in favor of 2 factor auth
#    line 207: moved the Replace(" ","") to remove spaces in platform ID from line 90 to this line, just so the syntax looked cleaner up above
#    line 210-212: added additional parameters for AD/oracle accounts
#    line 230: updated the if/$getResult count to be "-gt 0" otherwise it would never add an account for me. Since if it counts something that is the same username/address then the count would be 1
#    line 235-246: added if else statement for different types of accounts
#
# BUG: If multiple account types (e.g., Oracle and AD) are in the same import file, then the additional properties (Port, LogonDomain, Database) can show up on accounts as artifacts.
#        Example: if row two has an account with Port/Database populated, then row 3 might also have port and database get populated, even if it is blank. I am not sure why, maybe a caching issue?
#        Workaround: just use separate import files for different types of accounts (1 file for Oracle, 1 for AD, 1 for local, etc)
#
# TODO: add parameter for "Limit Domain Access To"
#
#########################################################################

## Use TLS 1.2 instead of default 1.0
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

## FUNCTIONS FIRST!
function OpenFile-Dialog($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

function PASREST-Logon {

    # Declaration
    $webServicesLogon = "$baseURL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon"

    # Authentication - changed
    ## use this for hard-coded LDAP or password authentication
    #$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Global:apiPassword)
    #$apiPasswordPT = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    ##use this for 2-factor authentication
    $password = Read-Host -Prompt Password -AsSecureString
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    #if using LDAP or password auth then change "useRadiusAuthentication to "False", uncomment lines 47 and 48 and 165, and comment out lines 51 an d 52
    $bodyParams = @{username = "$apiUsername"; password = $password; useRadiusAuthentication = "true"; connectionNumber = "25"} | ConvertTo-JSON

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

function PASREST-GetAccount ([string]$Authorization,[string]$Address,[string]$Username,[string]$Safe="") {
    # Declaration
    $webServicesGetAccount = "$baseURL/PasswordVault/WebServices/PIMServices.svc/Accounts"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$Authorization)
    $requestURI = "$($webServicesGetAccount)?Keywords=$($Address),$($Username)"
    if ($safe -ne "") {
        $requestURI = "$($requestURI)&Safe=$($Safe)"
    }
    # Execution
    Write-Host "Request URI: $($requestURI)"
    try {
        $getAccountResult = Invoke-RestMethod -Uri "$($requestURI)" -Method GET -Header $headerParams -ErrorVariable getAccountResultErr
        return $getAccountResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

#added additional parameters to function
function PASREST-AddAccount ([string]$Authorization,[string]$ObjectName,[string]$Safe,[string]$PlatformID,[string]$Address,[string]$Username,[string]$Password,[string]$DisableAutoMgmt,[string]$DisableAutoMgmtReason,[string]$database,[string]$port,[string]$logonDomain) {

    # Declaration
    $webServicesAddAccount = "$baseURL/PasswordVault/WebServices/PIMServices.svc/Account"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$Authorization)

    #depending on what fields are populated in the row it will assume they are different types of accounts and send different body params
    if ($database) {
        $bodyParams = @{"account"=@{"safe"="$Safe";"platformID"="$PlatformID";"address"="$Address";"accountName"="$ObjectName";"password"="$Password";"username"="$Username";"disableAutoMgmt"="$DisableAutoMgmt";"disableAutoMgmtReason"="$DisableAutoMgmtReason";"properties"=@(@{Key="port";Value="$port"};@{Key="database";Value="$database"})}}
    } elseif ($port) {
        $bodyParams = @{"account"=@{"safe"="$Safe";"platformID"="$PlatformID";"address"="$Address";"accountName"="$ObjectName";"password"="$Password";"username"="$Username";"disableAutoMgmt"="$DisableAutoMgmt";"disableAutoMgmtReason"="$DisableAutoMgmtReason";"properties"=@(@{Key="port";Value="$port"};@{Key="database";Value="$database"})}}
    } elseif ($logondomain) {
        $bodyParams = @{"account"=@{"safe"="$Safe";"platformID"="$PlatformID";"address"="$Address";"accountName"="$ObjectName";"password"="$Password";"username"="$Username";"disableAutoMgmt"="$DisableAutoMgmt";"disableAutoMgmtReason"="$DisableAutoMgmtReason";"properties"=@(@{Key="logonDomain";Value="$logonDomain"})}}
    } else {
        $bodyParams = @{"account"=@{"safe"="$Safe";"platformID"="$PlatformID";"address"="$Address";"accountName"="$ObjectName";"password"="$Password";"username"="$Username";"disableAutoMgmt"="$DisableAutoMgmt";"disableAutoMgmtReason"="$DisableAutoMgmtReason"}}
    }

    $bodyParams = ConvertTo-JSON $bodyParams -Depth 4

    #allows to see JSON being sent to server; used for debugging if methods are failing
    #Write-host $bodyParams 

    # Execution
    try {
        $addAccountResult = Invoke-RestMethod -Uri $webServicesAddAccount -Method POST -ContentType "application/json" -Header $headerParams -Body $bodyParams -ErrorVariable addAccountResultErr
        return $addAccountResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

function PASREST-Logoff ([string]$Authorization) {

    # Declaration
    $webServicesLogoff = "$baseURL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logoff"

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

## SPLASH SCREEN
Write-Host "Welcome to Password Upload Utility v2" -ForegroundColor "Yellow"
Write-Host "=====================================" -ForegroundColor "Yellow"
Write-Host " "

## USER INPUT
$Global:baseURL = Read-Host "Please enter your PVWA address (https://pvwa.cyberark.local)"
$Global:apiUsername = Read-Host "Please enter your REST API Username (CyberArk/LDAP/RADIUS)"
#apiPassword only used for password auth, not radius
#$Global:apiPassword = Read-Host "Please enter ${apiUsername}'s password" -AsSecureString
$csvPath = OpenFile-Dialog($Env:CSIDL_DEFAULT_DOWNLOADS) 



## LOGON TO CYBERARK WEB SERVICES
$sessionID = PASREST-Logon
Write-Host "Session ID: ${sessionID}"

# Error Handling for Logon
if ($sessionID -eq $false) { Write-Host "[ERROR] There was an error logging into the Vault." -ForegroundColor "Red"; break }
else { Write-Host "[INFO] Logon completed successfully." -ForegroundColor "DarkYellow" }

## IMPORT CSV
$csvRows = Import-Csv -Path $csvPath
# Count the number of rows in the CSV
$rowCount = $csvRows.Count
$counter = 0

## STEP THROUGH EACH CSV ROW
foreach ($row in $csvRows) {

    # INCREMENT COUNTER
    $counter++

    # added variables for oracle/AD account types
    # DEFINE VARIABLES FOR EACH VALUE
    $objectName             = $row.ObjectName
    $safe                   = $row.Safe
    $password               = $row.Password
    $platformID             = $row.PlatformID.Replace(" ","")
    $address                = $row.Address
    $username               = $row.Username
    $database               = $row.Database
    $port                   = $row.Port
    $logonDomain            = $row.LogonDomain

    # If DisableAutoMgmt is yes or true, disable it.  Otherwise, ignore.
    if ($row.DisableAutoMgmt -eq "yes" -or $row.DisableAutoMgmt -eq "true") {
        $disableAutoMgmt = "true"
    } else {
        $disableAutoMgmt = "false"
    }
    if ($disableAutoMgmt -eq "true") {
        $disableAutoMgmtReason = $row.DisableAutoMgmtReason
    } else {
        $disableAutoMgmtReason = ""
    }

    #CHECK IF ACCOUNT ALREADY EXISTS IN VAULT
    $getResult = PASREST-GetAccount -Authorization $sessionID -Address $address -Username $username -Safe $safe 
    if ($getResult -ne $false) {
        # If results are returned matching the specific username and address combination, break to the next row.
        if([int]$getResult.Count -gt 0) { Write-Host "[ERROR] Username ${username}@${address} already exists in the Vault." -ForegroundColor "Red"; continue }
    }

    #if else statement has different parameters for different types of accounts
    # ADD ACCOUNT TO VAULT
    if (-NOT([String]::IsNullOrEmpty($database))) {
        $addResult = PASREST-AddAccount -Authorization $sessionID -ObjectName $objectName -Safe $safe -PlatformID $platformID -Address $address -Username $username -Password $password -DisableAutoMgmt $disableAutoMgmt -DisableAutoMgmtReason $disableAutoMgmtReason `
            -database $database -port $port
    } elseif (-NOT([String]::IsNullOrEmpty($port))) {
        $addResult = PASREST-AddAccount -Authorization $sessionID -ObjectName $objectName -Safe $safe -PlatformID $platformID -Address $address -Username $username -Password $password -DisableAutoMgmt $disableAutoMgmt -DisableAutoMgmtReason $disableAutoMgmtReason `
            -database $database -port $port
    } elseif (-NOT([String]::IsNullOrEmpty($logonDomain))) {
        $addResult = PASREST-AddAccount -Authorization $sessionID -ObjectName $objectName -Safe $safe -PlatformID $platformID -Address $address -Username $username -Password $password -DisableAutoMgmt $disableAutoMgmt -DisableAutoMgmtReason $disableAutoMgmtReason `
            -logonDomain $logonDomain
    } else {
        $addResult = PASREST-AddAccount -Authorization $sessionID -ObjectName $objectName -Safe $safe -PlatformID $platformID -Address $address -Username $username -Password $password -DisableAutoMgmt $disableAutoMgmt -DisableAutoMgmtReason $disableAutoMgmtReason
    }

    # If nothing is returned, there was an error and it will break to next row.
    if ($addResult -eq $false) { Write-Host "[ERROR] There was an error adding ${username}@${address} into the Vault." -ForegroundColor "Red"; continue }
    else { Write-Host "[INFO] [${counter}/${rowCount}] Added ${username}@${address} successfully." -ForegroundColor "DarkYellow" }
}

$logoffResult = PASREST-Logoff -Authorization $sessionID
# If a value is returned, logoff was successful.
if ($logoffResult -eq $true) {Write-Host "[INFO] Logoff completed successfully." -ForegroundColor DarkYellow}
else {Write-Host "[ERROR] Logoff was not completed successfully.  Please logout manually using Authorization token: ${sessionID} or wait until PVWATimeout occurs." -ForegroundColor Red}

Write-Host " "
Write-Host "=====================================" -ForegroundColor "Yellow"
Write-Host "Vaulted ${counter} out of ${rowCount} accounts successfully."
