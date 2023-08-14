# #!/bin/bash

os_name=$(uname)

# Install dependencies
if [ "$os_name" = "Linux" ]; then
    if ! [ -x "$(command -v azcopy)" ]; then
        sudo bash -c 'cd /usr/local/bin; curl -L https://aka.ms/downloadazcopy-v10-linux | tar --strip-components=1 --exclude=*.txt -xzvf -; chmod +x azcopy'
    fi
elif [ "$os_name" = "Darwin" ]; then
    if ! [ -x "$(command -v azcopy)" ]; then
        brew install azcopy
    fi
fi

# Pull in variables from .env file in the same folder as this script
source "./.env"

# Validate variables
if [ -z "$SAS_URL" ]; then
    echo "SAS_URL is not set in the .env file. Please set it to the SAS URL and run the script again"
    exit 1
fi

if [ -z "$SAS_TOKEN" ]; then
    echo "SAS_TOKEN is not set in the .env file. Please set it to the SAS TOKEN and run the script again"
    exit 1
fi

echo "SAS_URL is set to $SAS_URL"
echo "SAS_TOKEN is set to $SAS_TOKEN"

uploadFile() 
{
    filePath=$1
    folderName=$2
    echo "Uploading file to Azure from $filePath"
    destination="$SAS_URL/$folderName/$(basename $filePath)?$SAS_TOKEN"
    echo "Destination: $destination"
    azcopy cp "$filePath" "$destination"
}

index=1
while [ "$index" -le 100 ]; do
    file_variable="FILE_UPLOAD_PATH_$index"
    folder_variable="FILE_AZURE_FOLDER_$index"
    file=${!file_variable}
    folder=${!folder_variable}

    if [ -z "$file" ]; then
        index=$((index + 1))
        continue
    fi

    uploadFile "$file" "$folder"

    index=$((index + 1))
done

echo "File upload(s) complete"