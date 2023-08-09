
#!/bin/bash

# Variables
APP_FOLDER="azure_uploader"

cd "$HOME"

# Create application folder
if [ ! -d "$APP_FOLDER" ]
then
    mkdir "$APP_FOLDER"
fi

# Navigate to application folder
cd "$APP_FOLDER"

# Download the azure uploader script
curl -sS -O https://raw.githubusercontent.com/chishingchang-sparqueai/azure_uploader/main/azure_upload_linux_mac.sh

# Set permissions
chmod +x azure_upload_linux_mac.sh

# Download the .env example
curl -sS -O https://raw.githubusercontent.com/chishingchang-sparqueai/azure_uploader/main/.env.example
mv .env.example .env

echo "Please edit the .env file in the $APP_FOLDER folder to configure the script for uploads."
echo "After that, run the script with the following command:"
echo
echo "./azure_upload_linux_mac.sh"