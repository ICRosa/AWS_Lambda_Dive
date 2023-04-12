'''
By default, the function requires:

Athena configured with prepared statement # hourly_query

S3 for destination

IAM with access to Athena and S3 services # prepared statement needs to be included

An event containing: {
    "time_string": Timestring on format "%Y-%m-%d-%H",
    "job_id": String
    }

'''




import boto3
import time
import os

# get the target bucket from an environment variable
target_bucket = os.getenv('target_bucket')

def lambda_handler(event, context):
    
    # create a client object for AWS Athena
    client = boto3.client('athena', 'us-east-1')
    
    # get the time string from the input event
    ts = event['time_string']
    ts = ts[:10] + " " + ts[11:]
    
    # query Athena to get the name of the table to use
    table_name = client.start_query_execution(
        QueryString="SELECT table_name FROM information_schema.tables WHERE table_name LIKE 'ghadata%'",
        ResultConfiguration= {'OutputLocation': f's3://{target_bucket}/GHA-group/'},
        WorkGroup='gha'
    )
    
    # wait for the query to finish executing
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
        
    # get the name of the table from the query results
    table_name = client.get_query_results(
        QueryExecutionId=table_name['QueryExecutionId'],
        MaxResults=1
    )
    
    # run the count query
    response = client.start_query_execution(
        QueryString=f"SELECT count(\"created_at\") FROM \"gha-db\".\"{table_name}\" WHERE created_at BETWEEN TIMESTAMP '{ts}:00' AND TIMESTAMP '{ts}:59:59'",
        ResultConfiguration= {'OutputLocation': f's3://{target_bucket}/GHA-group/'},
        WorkGroup='gha'
    )
        
    # wait for the count query to finish executing
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
    
    # get the count result from the query results
    responser = client.get_query_results(
        QueryExecutionId=response['QueryExecutionId'],
        MaxResults=3
    )

    # return the job ID, HTTP status code, and query result
    return {
        'job_id': event['job_id'],
        'statusCode': responser['ResponseMetadata']['HTTPStatusCode'],
        'result': responser['ResultSet']['Rows'][1]['Data'][0]['VarCharValue']
    }