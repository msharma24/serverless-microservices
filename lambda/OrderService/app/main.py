from fastapi import FastAPI, status
from app.routers import orders
from mangum import Mangum

from aws_lambda_powertools import Metrics, Logger, Tracer

# Set up logger
logger = Logger()
tracer = Tracer()
metrics = Metrics()



PROJECT_NAME="order-service-lambda-api"

app = FastAPI(
    title=PROJECT_NAME,
    openapi_prefix="/dev"
)


@app.get("/", status_code=status.HTTP_200_OK)
def health_check():
    return {"msg": "OK"}


app.include_router(orders.router, prefix="/orders")


handler = Mangum(app, lifespan="off")
logger.info("Mangum app.")
