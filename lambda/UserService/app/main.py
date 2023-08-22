from fastapi import FastAPI, status
from pydantic import BaseModel
from fastapi.responses import JSONResponse, Response
from pathlib import Path
import json
from aws_lambda_powertools import Metrics, Logger, Tracer
from fastapi import FastAPI, HTTPException
import boto3
import botocore
import uuid
import os
from mangum import Mangum
from app.models.users import UserInputModel


# Set up logger
logger = Logger()
tracer = Tracer()
metrics = Metrics()

AWS_REGION=os.environ.get('AWS_REGION')
DYNAMODB_TABLE=os.environ.get('DYNAMODB_TABLE')
PROJECT_NAME="user-service-lambda-api"

#app = FastAPI()
app = FastAPI(
    title=PROJECT_NAME,
    # if not custom domain
    openapi_prefix="/dev"
)

logger.info("FastAPI app initialized")

# class UserInputModel(BaseModel):
#     username: str
#     email: str
#     name: str


@app.get("/", status_code=status.HTTP_200_OK)
async def root():
    return {"message": "Welcome, to UserService hit /docs#"}


@app.get("/get-all-items")
async def get_all_items():
    try:
        client = boto3.client('dynamodb', region_name=AWS_REGION)
        response = client.scan(
            TableName=DYNAMODB_TABLE
        )
        items = response.get("Items", [])
        return items
    except Exception as e:
        logger.error(e)
        return {"error": str(e)}


@app.post("/add_user/")
async def add_user(user_input: UserInputModel):
    try:
        username = user_input.username
        name = user_input.name
        email  = user_input.email

        client = boto3.client('dynamodb', region_name=AWS_REGION)
        response = client.transact_write_items(
                TransactItems=[
                    {
                        'Put': {
                            'TableName': DYNAMODB_TABLE,
                            'Item':{

                                'PK':{'S': f'CUSTOMER#{username}'},
                                'SK':{'S': f'CUSTOMER#{username}'},
                                'Username':{'S': f'{username}'},
                                'Name':{'S': f'{name}'},
                                'Email':{'S': f'{email}'},

                                },
                            'ConditionExpression': 'attribute_not_exists(PK)' 


                            }

                        },
                    {
                        'Put': {
                            'TableName': DYNAMODB_TABLE,
                            'Item': {

                                'PK':{'S': f'CUSTOMEREMAIL#{email}'},
                                'SK':{'S': f'CUSTOMEREMAIL#{email}'},


                                },
                            'ConditionExpression': 'attribute_not_exists(PK)'

                            }
                        }

                    ]
                )
        return {"message": f"User {username} with added successfully"}
    except Exception as e:
        if e.response['Error']['Code'] == 'TransactionCanceledException':
            logger.error(e)
            return {"message": f"Failed TransactionCanceledException"}
        else:
            raise e


@app.get("/users/{username}")
async def get_username(username: str):
    try:
        client = boto3.client('dynamodb', region_name=AWS_REGION)
        response = client.query(
                TableName=DYNAMODB_TABLE,
                KeyConditionExpression='#pk = :pk',
                ExpressionAttributeNames={
                    '#pk': 'PK'
                    },
                ExpressionAttributeValues={
                    ':pk': {'S': f'CUSTOMER#{username}'}
                    },
                ScanIndexForward=False,
                Limit=11

                )

        return response
    except Exception as e:
        logger.error(e)
        return {"error": str(e)}



@app.delete("/users/{username}")
async def delete_username(username: str):
    try:
        client = boto3.client('dynamodb', region_name=AWS_REGION)
        response = client.delete_item(
            TableName=DYNAMODB_TABLE,
            Key={
                'PK': {'S': f'CUSTOMER#{username}'},
                'SK': {'S': f'CUSTOMER#{username}'}
            }
        )
        return response
    except Exception as e:
        raise e



@app.post("/edit-address")
async def edit_address(username: str, new_address: str):
    try:
        client = boto3.client('dynamodb', region_name=AWS_REGION)
        response = client.transact_write_items(
                TransactItems=[
                    {
                        'Update': {
                            'TableName': DYNAMODB_TABLE,
                            'Key': {
                                'PK':{'S': f'CUSTOMER#{username}'},
                                'SK':{'S': f'CUSTOMER#{username}'},
                                },
                            'UpdateExpression': 'Set address = :new_address',
                            'ExpressionAttributeValues' : {
                                ':new_address' : {'S': new_address}
                                }
                            }
                        }
                    ]
                )
        return response
    except Exception as e:
        logger.error(e)
        raise e



handler = Mangum(app, lifespan="off")
logger.info("Mangum app.")
