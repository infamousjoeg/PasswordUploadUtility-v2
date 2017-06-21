# Password Upload Utility v2

[![CyberArk Ready](https://img.shields.io/badge/CyberArk-ready-blue.svg)](https://www.cyberark.com)[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://opensource.org/licenses/mit-license.php)[![GitHub forks](https://img.shields.io/github/forks/badges/shields.svg?style=social&label=Fork)]()[![GitHub stars](https://img.shields.io/github/stars/badges/shields.svg?style=social&label=Star)]()[![GitHub watchers](https://img.shields.io/github/watchers/badges/shields.svg?style=social&label=Watch)]()[![GitHub followers](https://img.shields.io/github/followers/espadrine.svg?style=social&label=Follow)]()

Updated Password Upload Utility utilizing the REST API instead of an outdated and restricted version of PACLI.

## WELCOME CYBERARK IMPACT 2017 ATTENDEES!

Thank you for attending the **REST for the Rest of Us** breakout session!

## Usage

Download the ZIP file or ```git clone``` to a directory.

Open _passwords.csv_ and begin adding your account information.  Acceptable values for DisableAutoMgmt are yes or true.  Anything else will be considered a no.

Start > Run ```powershell```

```cd``` to the directory _PasswordUploadUtility-v2.ps1_ is located.

```.\PasswordUploadUtility-v2.ps1```

## TODO

* Add Bulk Change Method
* Add Additional Properties for non-Windows accounts