'''
  Por padrão função requer:

    Athena configurado com prepared Statement   # hourly_query
    
    S3 para destino
    
    IAM com acesso a serviços Athena e S3       # precisa incluir prepared Statement

    Um evento contendo: { 
        "time_string" : Timestring formato "%Y-%m-%d-%H",
        "job_id" : String
        }
'''




import boto3
import time
import os

target_bucket = os.getenv('target_bucket')

def lambda_handler(event, context):
    
    client = boto3.client('athena', 'us-east-1')
    
    ts = event['time_string']
    ts = ts[:10] + " " + ts[11:]
    
    #pega o nome da mesa criada
    
    
    table_name = client.start_query_execution(
        QueryString="SELECT table_name FROM information_schema.tables WHERE table_name LIKE 'ghadata%'",
        ResultConfiguration= {'OutputLocation': f's3://{target_bucket}/GHA-group/'},
        WorkGroup='gha'
    )
    
    while True:
        time.sleep(2)
        finish_state = client.get_query_execution(QueryExecutionId=table_name['QueryExecutionId'])[
            "QueryExecution"
        ]["Status"]["State"]
        
        print(finish_state)
        if finish_state == "RUNNING" or finish_state == "QUEUED":
            time.sleep(7)
        else:
            break
        
        
    table_name = client.get_query_results(
        QueryExecutionId=table_name['QueryExecutionId'],
        MaxResults=1
    )
    
    
    # Realiza a  query
    response = client.start_query_execution(
        QueryString=f"SELECT count(\"created_at\") FROM \"gha-db\".\"{table_name}\" WHERE created_at BETWEEN TIMESTAMP '{ts}:00' AND TIMESTAMP '{ts}:59:59'",
        ResultConfiguration= {'OutputLocation': f's3://{target_bucket}/GHA-group/'},
        WorkGroup='gha'
    )
        
    
    
    # Espera query terminar
    while True:
        time.sleep(2)
        finish_state = client.get_query_execution(QueryExecutionId=response['QueryExecutionId'])[
            "QueryExecution"
        ]["Status"]["State"]
        
        print(finish_state)
        
        if finish_state == "RUNNING" or finish_state == "QUEUED":
            time.sleep(7)
        else:
            break
    
    
    
    # Pega o Resultado da Query
    responser = client.get_query_results(
        QueryExecutionId=response['QueryExecutionId'],
        MaxResults=3
    )

    
    return {
        'job_id': event['job_id'],
        'statusCode': responser['ResponseMetadata']['HTTPStatusCode'],
        'result': responser['ResultSet']['Rows'][1]['Data'][0]['VarCharValue']
    }