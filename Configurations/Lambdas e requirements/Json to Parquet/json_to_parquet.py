''' 
Função conerte arquivos Json, de um S3, para snappy.parquet(s) guardados em outro S3

• Essa função espera um triger PUT de um S3 
• Requer fastparquet, fsspec e dependencias - náo foi testada sem s3fs
'''
import boto3
import pandas as pd
import uuid

def lambda_handler(event, context):
    
    job_id = event['job_id']
    origin_bucket_name, file_key = [event['Bucket'], event['Key']]
    target_bucket = "arch-reciever"
    
    
    df_reader = pd.read_json(
        f's3://{origin_bucket_name}/{file_key}',
        lines=True,
        orient='records',
        chunksize=1000
    )

    for idx, df in enumerate(df_reader):
        target_file_name = (f'{file_key.split(".")[0].replace("-", "/")}' + "/" + 
            f'{file_key.split(".")[0].split("/")[1].replace("-", "")}-{uuid.uuid1()}.snappy.parquet')

        print(f'Processing chunk {idx} of size {df.shape[0]} from file {file_key.split("/")[-1]}')
        df.drop(columns=['payload']). \
        to_parquet(
            f's3://{target_bucket}/{target_file_name}',
            index=False,
            engine='fastparquet'
        )
        number_of_files = idx
        break
    number_of_files += 1
    
    return {
        'job_id': job_id,
        'time_string' : event['time_string'],
        'body': f'{number_of_files} Parquet files converted from bucket {origin_bucket_name} file {file_key}'
    }