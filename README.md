# Password Upload Utility v2
## PUU 2

**_This is not supported by CyberArk.  It is an open source community project._**

[![CyberArk Ready](https://img.shields.io/badge/CyberArk-ready-blue.svg)](https://www.cyberark.com)[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://opensource.org/licenses/mit-license.php)

Updated Password Upload Utility utilizing the REST API instead of an outdated and restricted version of PACLI.

## WELCOME CYBERARK IMPACT 2017 ATTENDEES!

Thank you for attending the **REST for the Rest of Us** breakout session!

Did you miss my awesome presentation?  [Check it out on SlideShare!](https://www.slideshare.net/JoeGarciaCISSP/cyberark-impact-2017-rest-for-the-rest-of-us)

Love UNIX?  Us too!  [PUU 2 for Bash](https://github.com/infamousjoeg/PasswordUploadUtility-bash-v2)

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
