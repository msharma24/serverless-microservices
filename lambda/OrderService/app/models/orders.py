from pydantic import BaseModel, Extra, confloat, conint, constr


class CreateOrderModel(BaseModel):
    amount: confloat(gt=0)
    numItems: conint(gt=1)
    username: constr(
        strip_whitespace=True, min_length=2
    )  #! In Production, username will come from the auth token, for now, asking from FE

    class Config:
        schema_extra = {"example": {"amount": 5.5, "numItems": 2, "username": "john"}}


class UpdateOrderModel(BaseModel):
    username: constr(strip_whitespace=True)  #! same here, username will come from auth token
    status: constr(
        strip_whitespace=True
    )  #! in Production, this will be a enum, for now, accepting any string
