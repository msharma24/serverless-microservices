import os
import json
import boto3
from aws_lambda_powertools import Logger, Tracer

sns_client = boto3.client("sns")
TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
# Initialize Logger and Tracer
tracer = Tracer()
logger = Logger()


@tracer.capture_lambda_handler
def lambda_handler(event, context):
    try:
        for record in event["Records"]:
            if record["eventName"] in [
                "INSERT",
                "MODIFY",
            ]:  # Check if new item or item was modified
                new_image = record["dynamodb"].get("NewImage")

                if (
                    new_image and "OrderId" in new_image
                ):
                    sns_client.publish(
                        TopicArn=TOPIC_ARN,
                        Message=f"New entry added: {json.dumps(new_image)}",
                        Subject="New Entry in DynamoDB",
                    )
        logger.info("Function executed successfully!")
        return {
            "statusCode": 200,
            "body": json.dumps("Function executed successfully!"),
        }

    except Exception as e:
        logger.error(f"Error in processing: {str(e)}")
        return {"statusCode": 500, "body": json.dumps(f"Error in processing: {str(e)}")}
