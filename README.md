# serverless-microservices

# Introduction
The project uses FastAPI (https://fastapi.tiangolo.com/),  and the infrastructure is built using Terraform.

# Solution Architecture
![diagram](https://github.com/msharma24/serverless-microservices/blob/main/diagrams/serverless-microservices-aws.png)


# Services Tier
1 *UserService* - API Gateway REST API with Proxy Lambda function.
The UserService exposes the following endpoints.

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
