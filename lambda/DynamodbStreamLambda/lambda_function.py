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
    print(json.dumps(event))
    try:
        logger.debug(f"Received event: {json.dumps(event)}")

        event_name = event[0]['eventName']
        logger.info(f"event_name")
        if event_name in [
                "INSERT",
                "MODIFY"
                ]:
            new_image = event[0]['dynamodb'].get("NewImage")
            if (
                    new_image and 'OrderId' in new_image
                    ):
                sns_client.publish(
                        TopicArn=TOPIC_ARN,
                        Message=f"New entry added: {json.dumps(new_image)}",
                        Subject="New Entry in DDB"
                        )

        logger.info("SNS Sent successfully!")
        return {
            "statusCode": 200,
            "body": json.dumps("Function executed successfully!"),
        }

    except Exception as e:
        logger.error(f"Error in processing: {str(e)}")
        return {"statusCode": 500, "body": json.dumps(f"Error in processing: {str(e)}")}
