# Variables
$APP_FOLDER = "$env:USERPROFILE\azure_uploader"

# Create application folder if it doesn't exist
if (-not (Test-Path -Path $APP_FOLDER)) {
    New-Item -Path $APP_FOLDER -ItemType Directory
}

# Navigate to application folder
Set-Location -Path $APP_FOLDER

# Download the azure uploader script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chishingchang-sparqueai/azure_uploader/main/azure_upload_windows.ps1" -OutFile "azure_upload_windows.ps1"

# Download the .env example
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/chishingchang-sparqueai/azure_uploader/main/.env.ps1.example" -OutFile ".env.ps1"

if (-not (Test-Path .\env.ps1)) {
    Move-Item -Path .\env.ps1.example -Destination .\env.ps1
} else {
    Write-Output "env.ps1 already exists. Not overwriting."
}

Write-Output "Please edit the .env file in the $APP_FOLDER folder to configure the script for uploads."
Write-Output "We provided an example .env.ps1 file (.env.ps1.example) for you to use as a starting point."
Write-Output "Make a new .env.ps1 file or rename this file to .env.ps1 and edit it."
Write-Output "After that, run the script with the following command:"
Write-Output ""
Write-Output ".\azure_upload_windows.ps1"
