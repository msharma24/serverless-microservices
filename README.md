# serverless-microservices

# Introduction
The project uses FastAPI (https://fastapi.tiangolo.com/),  and the infrastructure is built using Terraform.

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
The OrderService maintains and manage order data
