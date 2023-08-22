from datetime import datetime
from decimal import Decimal

import simplejson as json
from boto3.dynamodb.conditions import Key
from fastapi import APIRouter, status
from ksuid import Ksuid
from aws_lambda_powertools import Metrics, Logger, Tracer
from app.models.orders import CreateOrderModel, UpdateOrderModel
from pydantic import constr
from app.utils import table


# Set up logger
logger = Logger()
tracer = Tracer()
metrics = Metrics()


router = APIRouter(tags=["order"])


@router.get("/")
def list(username: constr(strip_whitespace=True) = "john", nextToken: str = None):
    try:
        query = {
            "KeyConditionExpression": Key("PK").eq(f"CUSTOMER#{username}"),
            "ScanIndexForward": False,
            "Limit": 11,
        }
        if nextToken:
            query["ExclusiveStartKey"] = nextToken

        res = table.query(**query)
        items = res.get("Items", [])

        body = {"message": "orders fetched successfully", "data": items}
        if res.get("LastEvaluatedKey"):
            body["nextToken"] = res["LastEvaluatedKey"]

        return body

    except Exception as e:
        logger.error(f"error while fetching orders {e}")
        raise e


@router.post("/", status_code=status.HTTP_201_CREATED)
def create(payload: CreateOrderModel):
    order_id = str(Ksuid())
    item = {
        "PK": f"CUSTOMER#{payload.username}",
        "SK": f"#ORDER#{order_id}",
        "OrderId": order_id,
        "CreatedAt": datetime.utcnow().isoformat(),
        "Status": "PLACED",
        "Amount": payload.amount,
        "NumberItems": payload.numItems,
    }
    prep_item = json.loads(json.dumps(item), parse_float=Decimal)
    table.put_item(Item=prep_item)

    return {"message": "Order placed successfully", "success": True, "data": item}


@router.put("/{order_id}")
def update(
    payload: UpdateOrderModel,
    order_id: constr(strip_whitespace=True) = "2UHehGIqNG33x6y33bBKj1DMKvt",
):
    try:
        resp = table.update_item(
            Key={"PK": f"CUSTOMER#{payload.username}", "SK": f"#ORDER#{order_id}"},
            UpdateExpression="SET #status = :status, UpdatedAt = :updatedAt",
            ExpressionAttributeNames={"#status": "Status"},
            ExpressionAttributeValues={
                ":status": payload.status,
                ":updatedAt": datetime.utcnow().isoformat(),
            },
            ReturnValues="ALL_NEW",
            ConditionExpression="attribute_exists(PK) and attribute_exists(SK)",
        )

        return {
            "message": "Order updated successfully",
            "success": True,
            "data": resp.get("Attributes"),
        }
    except Exception as e:
        logger.error(f"error while updating order {e}")
        raise e


@router.get("/{order_id}")
def get(
    order_id: constr(strip_whitespace=True) = "2UHehGIqNG33x6y33bBKj1DMKvt",
    customer_id: constr(strip_whitespace=True) = "john",
):
    try:
        resp = table.get_item(Key={"PK": f"CUSTOMER#{customer_id}", "SK": f"#ORDER#{order_id}"})
        item = resp.get("Item")
        if not item:
            return {"message": "Order not found", "success": False, "status": 404}

        return {
            "message": "Order fetched successfully",
            "success": True,
            "data": item,
            "status": 200,
        }
    except Exception as e:
        logger.error(f"error while fetching order {e}")
        raise e
