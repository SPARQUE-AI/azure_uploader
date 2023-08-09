# #!/bin/bash

os_name=$(uname)

# Install dependencies
if [ "$os_name" = "Linux" ]; then
    if ! [ -x "$(command -v azcopy)" ]; then
        # Download and extract
        wget https://aka.ms/downloadazcopy-v10-linux
        tar -xvf downloadazcopy-v10-linux

        # Move AzCopy
        sudo rm -f /usr/bin/azcopy
        sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
        sudo chmod 755 /usr/bin/azcopy

        # Clean the kitchen
        rm -f downloadazcopy-v10-linux
        rm -rf ./azcopy_linux_amd64_*/
    fi
elif [ "$os_name" = "Darwin" ]; then
    if ! [ -x "$(command -v azcopy)" ]; then
        brew install azcopy
    fi
fi

# Pull in variables from .env file in the same folder as this script
source .env

# Validate variables
if [ -z "$SAS_URL" ]; then
    echo "SAS_URL is not set in the .env file. Please set it to the full SAS URL and run the script again"
    exit 1
fi

uploadFile() 
{
    filePath=$1
    echo "Uploading file to Azure from $filePath"
    azcopy cp "$filePath" "$SAS_URL"
}

# Handle the base "FILE" variable if it exists
if [ -n "$FILE_UPLOAD_PATH" ]; then
    uploadFile "$FILE_UPLOAD_PATH"
fi

index=0
while [ "$index" -le 10 ]; do
    var_name="FILE_UPLOAD_PATH_$index"
    file=${!var_name}

    if [ -z "$file" ]; then
        index=$((index + 1))
        continue
    fi

    uploadFile "$file"

    index=$((index + 1))
done

echo "File upload(s) complete"