import os

import boto3


AWS_REGION=os.environ.get('AWS_REGION')
DYNAMODB_TABLE=os.environ.get('DYNAMODB_TABLE')



client = boto3.Session(
    region_name=AWS_REGION,
)

db = client.resource("dynamodb")

table = db.Table(f"{DYNAMODB_TABLE}")
