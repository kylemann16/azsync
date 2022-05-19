#!/bin/bash

DESCRIPTION="Description:
	Sync Lidar collections from a given AWS S3 Bucket to an Azure Blob Storage Container.
	Output commands to stdout.


	Usage:
	--storage-account
		Specify the Azure Storage Account associated with you blob container.
	--sas-token
		Azure SAS Token that gives you permission to write to the Azure Blob Storage.
	--container-name
		Name of your Azure Blob Storage container (default: usgs-lidar)
	--azure-prefix
		Prefix behind which your lidar collections are stored in Azure (default: Projects)
	--access-key
		AWS Access Key Id that gives you permission to access this S3 Bucket.
	--secret
		AWS Secret Access Key that gives you permission to access this S3 Bucket.
	--bucket-name
		AWS S3 Bucket Name (default: usgs-lidar)
	--s3-prefix
		Prefix behind which your lidar collections are stored in S3 (default: Projects/)
	--help
		Display this message.
			"
if [[ -z $1 ]]; then
    echo -e "$DESCRIPTION"
	exit
fi

while [[ $# -gt 0 ]]; do
	case $1 in
		--storage-account)
			export AZURE_STORAGE_ACCOUNT="$2"
			shift # past argument
			shift # past value
			;;
		--sas-token)
			export AZURE_SAS_TOKEN="$2"
			shift # past argument
			shift # past value
			;;
		--container-name)
			export AZURE_CONTAINER_NAME="$2"
			shift # past argument
			shift # past value
			;;
		--azure-prefix)
			export AZURE_PREFIX="$2"
			shift # past argument
			shift # past value
			;;
		--access-key)
			export AWS_ACCESS_KEY_ID="$2"
			shift # past argument
			shift # past value
			;;
		--secret)
			export AWS_SECRET_ACCESS_KEY="$2"
			shift # past argument
			shift # past value
			;;
		--bucket-name)
			export AWS_S3_BUCKET_NAME="$2"
			shift # past argument
			shift # past value
			;;
		--s3-prefix)
			export AWS_PREFIX="$2"
			shift # past argument
			shift # past value
			;;
		--help)
			echo -e "$DESCRIPTION"
			exit
			shift
			;;
	esac
done


echo --------------------  Azure  -----------------------

echo Storage Account: $AZURE_STORAGE_ACCOUNT
echo SAS Token: $AZURE_SAS_TOKEN
echo Container Name: $AZURE_CONTAINER_NAME
echo Azure Prefix: $AZURE_PREFIX
echo Azure URI: "https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${AZURE_CONTAINER_NAME}/${AZURE_PREFIX}"

echo ---------------------  AWS  ------------------------

echo AWS Access Key: $AWS_ACCESS_KEY_ID
echo AWS Secret: $AWS_SECRET_ACCESS_KEY
echo Bucket Name: $AWS_S3_BUCKET_NAME
echo AWS Prefix: $AWS_PREFIX
echo AWS Uri: "https://s3.amazonaws.com/${AWS_S3_BUCKET_NAME}/${AWS_PREFIX}"

echo ----------------------------------------------------

## Find the difference between the aws directory and the azure directory
python3 diff.py