# Winget-AllinOne
Install apps one shot + Winget-AutoUpdate

## Info
Based on
- https://github.com/Romanitho/Winget-AutoUpdate
- https://github.com/Romanitho/Winget-Install

[Download projet](https://github.com/Romanitho/Winget-AllinOne/archive/refs/heads/main.zip) and extract.

Put the Winget Application IDs in "apps_to_install.txt" file to install them in bulk.

Put the Winget Application IDs in "excluded_apps.txt" file to exclude them from daily upgrade job. By defaut, if this file is not present, it will use the default one from Winget-AutoUpgrade repo.

Then, run install.bat
