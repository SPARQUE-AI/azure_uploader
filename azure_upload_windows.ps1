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
. ".\.env.ps1"

# Validate variables
if (-not $SAS_URL) {
    Write-Output "SAS_URL is not set in the .env file. Please set it to the SAS URL and run the script again"
    exit
}

if (-not $SAS_TOKEN) {
    Write-Output "SAS_TOKEN is not set in the .env file. Please set it to the SAS TOKEN and run the script again"
    exit
}

function UploadFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$filePath,

        [Parameter(Mandatory=$false)]
        [string]$folderName
    )

    Write-Output "Uploading file to Azure from $filePath"
    
    $fileName = [System.IO.Path]::GetFileName($filePath)

    if (-not [string]::IsNullOrEmpty($folderName)) {
        $destination = "$env:SAS_URL/$folderName/$fileName?$env:SAS_TOKEN"
    } else {
        $destination = "$env:SAS_URL/$fileName?$env:SAS_TOKEN"
    }

    Write-Output "Destination: $destination"
    azcopy cp $filePath $destination
}


for ($index=1; $index -le 100; $index++) {
    $fileVariableName = "FILE_UPLOAD_PATH_$index"
    $folderVariableName = "FILE_AZURE_FOLDER_$index"

    $file = Get-Variable -Name $fileVariableName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value
    $folder = Get-Variable -Name $folderVariableName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Value

    if (-not $file) {
        continue
    }

    UploadFile -filePath $file -folderName $folder
}

Write-Output "File upload(s) complete"
