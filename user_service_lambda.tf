module "user_service_lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.2.0"

  function_name = "${var.environment}-phoenix-lambda"
  description   = "FastAPI lambda function"
  handler       = "app.main.handler"
  runtime       = "python3.9"
  create_role   = true

  memory_size = "128"
  timeout     = "300"

  local_existing_package  = module.user_service_lambda_package.local_filename
  ignore_source_code_hash = false
  create_package          = false


  layers = [
    local.lambda_powertools_layer_arn
    # https://awslabs.github.io/aws-lambda-powertools-python/2.11.0/
  ]




  environment_variables = {
    LOG_LEVEL               = "INFO"
    POWERTOOLS_SERVICE_NAME = "userService"
    ENV                     = var.environment
    DYNAMODB_TABLE          = aws_dynamodb_table.ecommerce_table.id



  }

  attach_policy_json = true

  policy_json = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ssm:GetParameter",
              "kms:Decrypt",
              "dynamodb:*"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF

  tags = {
    Name = "${var.environment}-phoenix-Lambda"
  }


}



# Lambda Permission
resource "aws_lambda_permission" "user_service_apigw_lambda_2" {
  statement_id  = "AllowExecutionFromAPIGateway-2"
  action        = "lambda:InvokeFunction"
  function_name = module.user_service_lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.user_service_rest_api.id}/*/*/"
}



resource "aws_lambda_permission" "user_service_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.user_service_lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.user_service_rest_api.id}/*/${aws_api_gateway_method.user_service_api_proxy_method.http_method}${aws_api_gateway_resource.user_service_rest_api_proxy_resource.path}"
}
