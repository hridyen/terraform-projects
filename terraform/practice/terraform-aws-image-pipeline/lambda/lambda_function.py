import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMO_TABLE'])

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        size = record['s3']['object']['size']
        
        metadata = {
            'filename': key,
            'bucket': bucket,
            'size': size,
            'uploaded_at': datetime.utcnow().isoformat()
        }
        
        table.put_item(Item=metadata)

    return {"statusCode": 200, "body": json.dumps("Metadata stored")}
