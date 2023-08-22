# serverless-microservices

# Introduction
The project uses FastAPI (https://fastapi.tiangolo.com/), on AWS Lambda function with API GW  and the infrastructure is built using Terraform.

# Solution Architecture
![diagram](https://github.com/msharma24/serverless-microservices/blob/main/diagrams/serverless-microservices-aws.png)


# Services Tier
1 *UserService* - API Gateway REST API with Proxy Lambda function.
The UserService exposes the following endpoints to maintain and manage user.

`/add-user/{dict}`   - The `email` address and the `username` must always be unique - A duplicate record will result in Transaction Canceled error.
```
curl -X 'POST' \
  'https://{API_GW_ID}.execute-api.us-east-1.amazonaws.com/dev/add_user/' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "email": "test@gmail.com",
  "name": "Test Name",
  "username": "test111"
}'

{
  "message": "User test111 with added successfully"
}
```


`/users/{username}` - Prints the User Information
```
curl -X 'GET' \
  'https://xllrwe5j5k.execute-api.us-east-1.amazonaws.com/dev/users/test111' \
  -H 'accept: application/json'

```

`/edit-address/{username}{address_dict}` - Add/Edit/Update {username} address
```
curl -X 'POST' \
  'https://xllrwe5j5k.execute-api.us-east-1.amazonaws.com/dev/edit-address?username=test111&new_address=124%20Street%20Akl%20NZ' \
  -H 'accept: application/json' \
  -d ''
````


2 *OrderService* - API Gateway REST API with Proxy Lambda function.
The OrderService maintains and manages order data.
This service exposes the following endpoints.

`/orders/{username}` - Returns existing order information.
```
curl -X 'GET' \
  'https://{API_GW_ID}.execute-api.us-east-1.amazonaws.com/dev/orders/?username=john' \
  -H 'accept: application/json'


Returns

  "message": "orders fetched successfully",
  "data": [
    {
      "SK": "CUSTOMER#john",
      "PK": "CUSTOMER#john",
      "Email": "john@gmail.com",
      "Username": "john",
      "Name": "john smith"
    },
    {
      "NumberItems": 2,
      "SK": "#ORDER#2UJT4m2UkBAWG7DHDLfkXxbMN04",
      "Status": "PLACED",
      "Amount": 5.5,
      "PK": "CUSTOMER#john",
      "OrderId": "2UJT4m2UkBAWG7DHDLfkXxbMN04",
      "CreatedAt": "2023-08-21T22:21:34.811747"
    }
  ]
}

```
`/orders/{dict}` - Create new order
```
curl -X 'POST' \
  'https://{API_GW_ID}.execute-api.us-east-1.amazonaws.com/dev/orders/' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "amount": 5.5,
  "numItems": 2,
  "username": "john"
}'

Returns
{
  "message": "Order placed successfully",
  "success": true,
  "data": {
    "PK": "CUSTOMER#john",
    "SK": "#ORDER#2UJuYiRSoBMgAiXg7jBp0V0UqxU",
    "OrderId": "2UJuYiRSoBMgAiXg7jBp0V0UqxU",
    "CreatedAt": "2023-08-22T02:07:33.696174",
    "Status": "PLACED",
    "Amount": 5.5,
    "NumberItems": 2
  }
}

```
`/orders/{order_id}/{dict}` - Update order status
```
curl -X 'PUT' \
  'https://{API_GW_ID}.execute-api.us-east-1.amazonaws.com/dev/orders/2UJuYiRSoBMgAiXg7jBp0V0UqxU' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "username": "john",
  "status": "CANCEL"
}'
Returns
{
  "message": "Order updated successfully",
  "success": true,
  "data": {
    "UpdatedAt": "2023-08-22T02:09:03.577842",
    "NumberItems": 2,
    "SK": "#ORDER#2UJuYiRSoBMgAiXg7jBp0V0UqxU",
    "Status": "CANCEL",
    "Amount": 5.5,
    "PK": "CUSTOMER#john",
    "OrderId": "2UJuYiRSoBMgAiXg7jBp0V0UqxU",
    "CreatedAt": "2023-08-22T02:07:33.696174"
  }
}
````

