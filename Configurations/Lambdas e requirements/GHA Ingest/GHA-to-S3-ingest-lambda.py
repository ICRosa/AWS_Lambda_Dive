'''
Essa função faz um request de dados de uma URL ('https://data.gharchive.org/{file_name}'), carrega em um S3 e 
registra o processo em uma tabela Dynamo

• Requer layer AWSSDKPandas-Python39 ou ▼
    • requests e pytz

'''
import boto3
import requests
from datetime import datetime, timedelta
import os
import pytz


def lambda_handler(event, context):

    #Definindo variaveis gerais
    tz = pytz.timezone('UTC') #Garante a timezone UTC
    if os.name == 'nt':
        time_string = datetime.strftime(datetime.now(tz=tz) - timedelta(hours=1), "%Y-%m-%d-%#H")
        job_id = int(datetime.strftime(datetime.now(tz=tz) - timedelta(hours=1), "%Y%m%d%H"))
    else:
        time_string = datetime.strftime(datetime.now(tz=tz) - timedelta(hours=1), "%Y-%m-%d-%-H")
        job_id = int(datetime.strftime(datetime.now(tz=tz) - timedelta(hours=1), "%Y%m%d%H"))


    file_name = f'{time_string}.json.gz'
    bucket_name = 'raw-arch-entry'

    #Função coleta da fonte 
    def colect():
        arch = requests.get(f'https://data.gharchive.org/{file_name}')
        return arch

    #Função Ingere no S3 *bucket_name*
    def ingest():
        s3_client = boto3.client('s3')
        upload_res = s3_client.put_object(
        Bucket=bucket_name,
        Key=f'ghactivity/{file_name}',
        Body=arch.content
        )
        return upload_res
        
    #Função Registra na tabela "jobs" do Dynamo   
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

    arch = colect()
    upload_res = ingest()
    register()

    return {
      'job_id': f"{job_id}",
      'Bucket': bucket_name,
      'Key':f'ghactivity/{file_name}',
      'time_string': time_string,
      'status_code': upload_res['ResponseMetadata']['HTTPStatusCode']
    }