'''
This function makes a request for data from a URL ('https://data.gharchive.org/{file_name}'), loads it into an S3 bucket, and registers the process in a DynamoDB table.

• Requires AWSSDKPandas-Python39 layer or ▼
    • requests and pytz


'''
# Importing necessary modules
import boto3
import requests
from datetime import datetime, timedelta
import os
import pytz

# Get the target bucket name from environment variable
bucket_name = os.getenv('target_bucket')

# Lambda handler function
def lambda_handler(event, context):
    
    # Print the bucket name
    print(bucket_name)

    #Defining general variables
    tz = pytz.timezone('UTC') # Setting timezone to UTC
    if os.name == 'nt':
        # Windows OS
        time_string = datetime.strftime(datetime.now(tz=tz) - timedelta(hours=1), "%Y-%m-%d-%#H")
        job_id = int(datetime.strftime(datetime.now(tz=tz) - timedelta(hours=1), "%Y%m%d%H"))
    else:
        # Unix-based OS
        time_string = datetime.strftime(datetime.now(tz=tz) - timedelta(hours=1), "%Y-%m-%d-%-H")
        job_id = int(datetime.strftime(datetime.now(tz=tz) - timedelta(hours=1), "%Y%m%d%H"))

    file_name = f'{time_string}.json.gz'
    

    # Function to collect data from source
    def collect():
        arch = requests.get(f'https://data.gharchive.org/{file_name}')
        return arch

    # Function to ingest data into S3 bucket
    def ingest():
        s3_client = boto3.client('s3')
        upload_res = s3_client.put_object(
        Bucket=bucket_name,
        Key=f'ghactivity/{file_name}',
        Body=arch.content
        )
        return upload_res
        
    # Function to register job details in DynamoDB table "jobs"   
    def register():
        jobs_table = boto3.resource('dynamodb', 'us-east-1').Table('jobs')
        jobs_table.put_item(
            Item={
            'job_id': job_id,
            'job_type': 'ghactivity_ingest',
            'job_run_time': time_string,
             'job_run_bookmark_details': {
                'processed_file_name': file_name
             }})

    # Call the collect, ingest and register functions
    arch = collect()
    upload_res = ingest()
    register()

    # Returns a dictionary containing the following information:
    # - job_id: a string representation of the job ID
    # - Bucket: the target S3 bucket name
    # - Key: the S3 bucket key for the uploaded file
    # - time_string: a string representation of the time at which the job ran
    # - status_code: the HTTP status code of the S3 object upload operation
    return {
      'job_id': f"{job_id}",
      'Bucket': bucket_name,
      'Key':f'ghactivity/{file_name}',
      'time_string': time_string,
      'status_code': upload_res['ResponseMetadata']['HTTPStatusCode']
    }
