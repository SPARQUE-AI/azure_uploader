$APP_FOLDER = "$HOME\azure_uploader"
$os_name = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption

# Install dependencies
# Check for azcopy.exe file
if (-not (Test-Path ~\AppData\Local\Programs\AZCopy\azcopy.exe)) {
     Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile AzCopy.zip -UseBasicParsing
    Expand-Archive ./AzCopy.zip ./AzCopy -Force

    # Move AzCopy
    mkdir ~\AppData\Local\Programs\AZCopy
    Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination ~\AppData\Local\Programs\AZCopy\

    # Add AzCopy to PATH
    $userenv = (Get-ItemProperty -Path 'HKCU:\Environment' -Name Path).path
    $newPath = "$userenv;%USERPROFILE%\AppData\Local\Programs\AZCopy;"
    New-ItemProperty -Path 'HKCU:\Environment' -Name Path -Value $newPath -Force

    # Clean the kitchen
    del -Force AzCopy.zip
    del -Force -Recurse .\AzCopy\
}

# Pull in variables from .env file in the same folder as this script
. "$APP_FOLDER\.env.ps1"

# Validate variables
if (-not $SAS_URL) {
    Write-Output "SAS_URL is not set in the .env file. Please set it to the full SAS URL and run the script again"
    exit
}

function UploadFile {
    param (
        [string]$filePath
    )
    
    Write-Output "Uploading file to Azure from $filePath"
    & "$env:USERPROFILE\AppData\Local\Programs\AZCopy\azcopy.exe" cp "$filePath" "$SAS_URL"
}

# Handle the base "FILE" variable if it exists
if ($FILE_UPLOAD_PATH) {
    UploadFile -filePath $FILE_UPLOAD_PATH
}

$index = 0
while ($index -le 10) {
    $var_name = "FILE_UPLOAD_PATH_$index"
    $file = Get-Variable -Name $var_name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value

    if (-not $file) {
        $index++
        continue
    }

    UploadFile -filePath $file

    $index++
}

Write-Output "File upload(s) complete"
