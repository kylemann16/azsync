# Look at collections in usgs aws s3 bucket and compare with collections in
# azure blob storage. Any directories that don't exist in az blob storage should
# be copied over. This will be done by outputting a list of azcopy commands to run
# which will then each be run from the dockerfile that this is housed in.

import adlfs
import os
import boto3

def get_variable(name):
	try:
		return os.environ[name]
	except Exception as e:
		raise(f"Missing environment variable: {name}. {e}")

## Gather Variables
storage_account = get_variable('AZURE_STORAGE_ACCOUNT')
sas_token = get_variable('AZURE_SAS_TOKEN')
container = get_variable('AZURE_CONTAINER_NAME')
azure_collections_path = get_variable('AZURE_PREFIX')

access_key = get_variable('AWS_ACCESS_KEY_ID')
secret_key = get_variable('AWS_SECRET_ACCESS_KEY')
bucket_name = get_variable('AWS_S3_BUCKET_NAME')
s3_collections_path = get_variable('AWS_PREFIX')

## Get Azure Collections
azure_fs = adlfs.AzureBlobFileSystem(
	account_name=storage_account,
	sas_token=sas_token
)

azure_path = os.path.join(container, azure_collections_path)
azure_collections = [ os.path.basename(i) for i in azure_fs.ls(azure_path) ]


## Get AWS Collections
session = boto3.Session(
	aws_access_key_id=access_key,
	aws_secret_access_key=secret_key
)
s3_fs = session.client('s3', region_name='us-east-1')

aws_collections = []
continue_token=''
while True:
	if continue_token:
		one_ls = s3_fs.list_objects_v2(
			Bucket=bucket_name,
			Prefix=s3_collections_path,
			ContinuationToken=continue_token,
			Delimiter='/',
			RequestPayer='requester'
		)
	else:
		one_ls = s3_fs.list_objects_v2(
			Bucket=bucket_name,
			Prefix=s3_collections_path,
			Delimiter='/',
			RequestPayer='requester'
		)
	prefixes = [ i['Prefix'] for i in one_ls['CommonPrefixes']]
	aws_collections += [ os.path.basename(i[:-1]) for i in prefixes ]

	try:
		continue_token = one_ls['NextContinuationToken']
	except KeyError:
		break

## Get the difference and write scripts
collection_diff = [ i for i in aws_collections if i not in azure_collections ]

for collect in collection_diff:
	print(" ".join([
		'azcopy',
		'copy',
		f"'https://s3.amazonaws.com/{bucket_name}/Projects/{collect}'",
		f"'https://{storage_account}.blob.core.windows.net/{container}/Projects/{collect}?{sas_token}'",
		'--recursive'
	]) + "\n")