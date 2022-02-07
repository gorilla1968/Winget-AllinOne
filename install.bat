@echo off
powershell -Command "Get-ChildItem -Path '%~dp0' -Recurse | Unblock-File; Start-Process 'powershell.exe' -Wait -Argument '-executionpolicy bypass -file """%~dp0install.ps1"" '" -Verb RunAs