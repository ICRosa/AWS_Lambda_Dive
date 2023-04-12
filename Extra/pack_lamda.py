'''
This function loads a .zip file to create a layer containing the packages listed (with spaces) in {pack_names}.

Example:
pack_names = "fastparquet requests boto3"

• It does not require non-standard dependencies for lambda functions.
'''

import os
import boto3
import shutil

def lambda_handler(event, context):
    
    # name of the package
    pack_names = "fastparquet"
    
    # name of the destination bucket
    pack_bucket = 'lamblayers'
    
    # create directory to be zipped
    os.system("mkdir -p /tmp/layer/python")
    
    # pip command
    os.system(f"python -m pip install {pack_names} -t /tmp/layer/python")
    
    # create name without spaces for file
    zip_name = pack_names.replace(" ", "_")
    
    # zip and upload packages to S3
    s3_client = boto3.client('s3')
    s3_client.upload_file(shutil.make_archive('/tmp/layeronlamb', 'zip', '/tmp/layer'), pack_bucket, f'{zip_name}.zip')
    
    # return
    return {
        'statusCode': 200,
        'body': f"Check your bucket {pack_bucket} for {zip_name}.zip"
    }
