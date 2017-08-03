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
#               Add Additional Properties for non-Windows accounts
#
#########################################################################

## Use TLS 1.2 instead of default 1.0
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

## FUNCTIONS FIRST!
function OpenFile-Dialog($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

function PASREST-Logon {

    # Declaration
    $webServicesLogon = "$Global:baseURL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon"

    # Authentication
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Global:apiPassword)
    $apiPasswordPT = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    $bodyParams = @{username = $Global:apiUsername; password = ($apiPasswordPT)} | ConvertTo-JSON

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

function PASREST-AddAccount ([string]$Authorization,[string]$ObjectName,[string]$Safe,[string]$PlatformID,[string]$Address,[string]$Username,[string]$Password,[boolean]$DisableAutoMgmt,[string]$DisableAutoMgmtReason) {

    # Declaration
    $webServicesAddAccount = "$Global:baseURL/PasswordVault/WebServices/PIMServices.svc/Account"

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$Authorization)
    $bodyParams = @{account = @{safe = $Safe; platformID = $PlatformID.Replace(" ",""); address = $Address; accountName = $ObjectName; password = $Password; username = $Username; disableAutoMgmt = $DisableAutoMgmt; disableAutoMgmtReason = $DisableAutoMgmtReason}} | ConvertTo-JSON -Depth 2

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
    $webServicesLogoff = "$Global:baseURL/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logoff"

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

## DISABLE SSL VERIFICATION (THIS IS FOR DEV ONLY!)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

## SPLASH SCREEN
Write-Host "Welcome to Password Upload Utility v2" -ForegroundColor "Yellow"
Write-Host "=====================================" -ForegroundColor "Yellow"
Write-Host " "

## USER INPUT
$Global:baseURL = Read-Host "Please enter your PVWA address (https://pvwa.cyberark.local)"
$Global:apiUsername = Read-Host "Please enter your REST API Username (CyberArk/LDAP/RADIUS)"
$Global:apiPassword = Read-Host "Please enter ${apiUsername}'s password" -AsSecureString
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

    # DEFINE VARIABLES FOR EACH VALUE
    $objectName             = $row.ObjectName
    $safe                   = $row.Safe
    $password               = $row.Password
    $platformID             = $row.PlatformID
    $address                = $row.Address
    $username               = $row.Username

    # If DisableAutoMgmt is yes or true, disable it.  Otherwise, ignore.
    if ($row.DisableAutoMgmt -eq "yes" -or $row.DisableAutoMgmt -eq "true") {
        $disableAutoMgmt = $true
    } else {
        $disableAutoMgmt = $false
    }
    if ($disableAutoMgmt -eq $true) {
        $disableAutoMgmtReason = $row.DisableAutoMgmtReason
    } else {
        $disableAutoMgmtReason = ""
    }

    # ADD ACCOUNT TO VAULT
    $addResult = PASREST-AddAccount -Authorization $sessionID -ObjectName $objectName -Safe $safe -PlatformID $platformID -Address $address -Username $username -Password $password -DisableAutoMgmt $disableAutoMgmt -DisableAutoMgmtReason $disableAutoMgmtReason
    # If nothing is returned, there was an error and it will break to next row.
    if ($addResult -eq $false) { Write-Host "[ERROR] There was an error adding ${username}@${address} into the Vault." -ForegroundColor "Red"; break }
    else { Write-Host "[INFO] [${counter}/${rowCount}] Added ${username}@${address} successfully." -ForegroundColor "DarkYellow" }
}

$logoffResult = PASREST-Logoff -Authorization $sessionID
# If a value is returned, logoff was successful.
if ($logoffResult -eq $true) {Write-Host "[INFO] Logoff completed successfully." -ForegroundColor DarkYellow}
else {Write-Host "[ERROR] Logoff was not completed successfully.  Please logout manually using Authorization token: ${sessionID} or wait until PVWATimeout occurs." -ForegroundColor Red}

Write-Host " "
Write-Host "=====================================" -ForegroundColor "Yellow"
Write-Host "Vaulted ${counter} out of ${rowCount} accounts successfully."