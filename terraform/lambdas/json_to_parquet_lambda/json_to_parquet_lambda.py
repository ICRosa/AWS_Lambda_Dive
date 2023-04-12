''' 
This function converts JSON files from one S3 to snappy.parquet(s) format saved in another S3:

• This function expects a PUT trigger from an S3 bucket
• Requires fastparquet, fsspec, and dependencies - not tested without s3fs
'''


import boto3
import pandas as pd
import uuid
import os

def lambda_handler(event, context):
    # Extract required parameters from the event
    job_id = event['job_id']
    origin_bucket_name, file_key = [event['Bucket'], event['Key']]
    
    # Get the target bucket name from the environment variables
    target_bucket = os.getenv('target_bucket')
    
    # Read the JSON file from S3 in chunks of 1000 records
    df_reader = pd.read_json(
        f's3://{origin_bucket_name}/{file_key}',
        lines=True,
        orient='records',
        chunksize=1000
    )

    # Process each chunk and convert it to Parquet
    for idx, df in enumerate(df_reader):
        # Generate a unique file name for the Parquet file
        target_file_name = (
            f'{file_key.split(".")[0].replace("-", "/")}' + "/" + 
            f'{file_key.split(".")[0].split("/")[1].replace("-", "")}-{uuid.uuid1()}.snappy.parquet'
        )

        # Print information about the current chunk being processed
        print(f'Processing chunk {idx} of size {df.shape[0]} from file {file_key.split("/")[-1]}')
        
        # Remove the 'payload' column and write the data to a Parquet file in S3
        df.drop(columns=['payload']).to_parquet(
            f's3://{target_bucket}/{target_file_name}',
            index=False,
            engine='fastparquet'
        )
        
        # Keep track of the number of processed chunks
        number_of_files = idx
        
    # Increment the number of processed chunks to get the total number of generated files
    number_of_files += 1
    
    # Return a summary of the conversion process
    return {
        'job_id': job_id,
        'time_string' : event['time_string'],
        'body': f'{number_of_files} Parquet files converted from bucket {origin_bucket_name} file {file_key}'
    }