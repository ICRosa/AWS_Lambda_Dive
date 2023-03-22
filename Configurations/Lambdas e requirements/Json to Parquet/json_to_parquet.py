''' 
Função conerte arquivos Json, de um S3, para snappy.parquet(s) guardados em outro S3

• Essa função espera um triger PUT de um S3 
• Requer fastparquet, fsspec e dependencias - náo foi testada sem s3fs
'''

import pandas as pd
import uuid

def lambda_handler(event, context):
    
    #Bucket destino
    target_bucket = "arch-reciever"

    #
    origin_bucket_name, file_key = [event['Records'][0]['s3']['bucket']['name'], event['Records'][0]['s3']['object']['key']]
  
    
    df_reader = pd.read_json(
        f's3://{origin_bucket_name}/{file_key}',
        lines=True,
        orient='records',
        chunksize=10000
    )

    for idx, df in enumerate(df_reader):
        target_file_name = f'{file_key}/{uuid.uuid1()}.snappy.parquet'
        print(f'Processing chunk {idx} of size {df.shape[0]} from file {file_key.split("/")[-1]}')
        df.drop(columns=['payload']). \
        to_parquet(
            f's3://{target_bucket}/{target_file_name}',
            index=False,
            engine='fastparquet'
        )
        number_of_files = idx
        
    number_of_files += 1
    
    return {
        'body': f'{number_of_files} Parquet files converted from bucket {origin_bucket_name} file {file_key}'
    }
