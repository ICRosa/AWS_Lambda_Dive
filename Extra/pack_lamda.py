'''
Essa função carrega um .zip para criação de um layer contendo os pacotes listados (com espaço) em {pack_names}

exemplo:
    pack_names = "fastparquet requests boto3"

• Não requer dependencias não standard de funções lambda
'''

import os
import boto3
import shutil

def lambda_handler(event, context):
    
    #nome do pacote
    pack_names = "fastparquet"
    
    #Nome do bucket destino
    pack_bucket = 'meuslambdalayers'
    
    #cria diretorio a ser zipado
    os.system("mkdir -p /tmp/layer/python")
    
    #comando pip
    os.system(f"python -m pip install {pack_names} -t /tmp/layer/python")
    
    #cria nome sem espaços para arquivo
    zip_name = pack_names.replace(" ", "_")
    
    #zip e upload dos pacotes para S3
    s3_client = boto3.client('s3')
    s3_client.upload_file(shutil.make_archive('/tmp/layeronlamb', 'zip', '/tmp/layer'), pack_bucket, f'{zip_name}.zip')
    
    
    #Retorno
    return {
        'statusCode': 200,
        'body': f"Check your bucket {pack_bucket} for {zip_name}.zip"
    }