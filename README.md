# Password Upload Utility v2
## PUU 2

---

### **_This is not supported by CyberArk.  It is an open source community project._**

---

[![CyberArk Ready](https://img.shields.io/badge/CyberArk-ready-blue.svg)](https://www.cyberark.com)[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/infamousjoeg/PasswordUploadUtility-v2/master/LICENSE.md)
[![GitHub issues](https://img.shields.io/github/issues/infamousjoeg/PasswordUploadUtility-v2.svg)](https://github.com/infamousjoeg/PasswordUploadUtility-v2/issues)[![GitHub stars](https://img.shields.io/github/stars/infamousjoeg/PasswordUploadUtility-v2.svg)](https://github.com/infamousjoeg/PasswordUploadUtility-v2/stargazers)

Updated Password Upload Utility utilizing the REST API instead of an outdated and restricted version of PACLI.

## WELCOME CYBERARK IMPACT 2017 ATTENDEES!

Thank you for attending the **REST for the Rest of Us** breakout session!

Did you miss my awesome presentation?  [Check it out on SlideShare!](https://www.slideshare.net/JoeGarciaCISSP/cyberark-impact-2017-rest-for-the-rest-of-us)

Love UNIX?  Us too!  [PUU 2 for Bash](https://github.com/infamousjoeg/PasswordUploadUtility-bash-v2)

### Recently Added

* Get-Account will now confirm the Add-Account query did add the account!
* Changed out breaks to stop bad practice

## Requirements

PowerShell version 3.0 or above

## Usage

Download the ZIP file or ```git clone``` to a directory.

Open _passwords.csv_ and begin adding your account information.  Acceptable values for DisableAutoMgmt are yes or true.  Anything else will be considered a no.

Start > Run ```powershell```

```cd``` to the directory _PasswordUploadUtility-v2.ps1_ is located.

```.\PasswordUploadUtility-v2.ps1```

## PowerShell Function Examples

Available at [GitHub Gists](https://gist.github.com/infamousjoeg/9fd1ae60cdea88ac18dbbc49cf2bfe34)

[PSPete’s psPAS PowerShell Module on GitHub](https://github.com/pspete/psPAS)

## TODO 

* Add Bulk Change Switch
* Add Additional Properties for non-Windows accounts
