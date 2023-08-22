################################################################################
# API Gateway
################################################################################
resource "aws_api_gateway_rest_api" "order_service_rest_api" {
  name        = "${var.environment}-order-service-api"
  description = "Order Service FastAPI REST API"

}

resource "aws_api_gateway_method" "order_service_rest_api_get_method" {
  authorization = "NONE"
  http_method   = "ANY"
  resource_id   = aws_api_gateway_rest_api.order_service_rest_api.root_resource_id
  rest_api_id   = aws_api_gateway_rest_api.order_service_rest_api.id

}

resource "aws_api_gateway_integration" "order_service_rest_api_integration" {
  http_method             = aws_api_gateway_method.order_service_rest_api_get_method.http_method
  resource_id             = aws_api_gateway_rest_api.order_service_rest_api.root_resource_id
  rest_api_id             = aws_api_gateway_rest_api.order_service_rest_api.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.order_service_lambda_function.lambda_function_invoke_arn

}

resource "aws_api_gateway_resource" "order_service_rest_api_proxy_resource" {
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.order_service_rest_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.order_service_rest_api.id

}


resource "aws_api_gateway_method" "order_service_api_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.order_service_rest_api.id
  resource_id   = aws_api_gateway_resource.order_service_rest_api_proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.InvocationType" = false
  }


}
#
resource "aws_api_gateway_integration" "order_service_rest_api_integration_proxy" {
  http_method = aws_api_gateway_method.order_service_api_proxy_method.http_method
  #resource_id             = aws_api_gateway_rest_api.order_service_rest_api.root_resource_id
  resource_id             = aws_api_gateway_resource.order_service_rest_api_proxy_resource.id
  rest_api_id             = aws_api_gateway_rest_api.order_service_rest_api.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.order_service_lambda_function.lambda_function_invoke_arn

}


resource "aws_cloudwatch_log_group" "order_service_rest_api_log_group" {
  name              = "API-Gateway-Execution-Logs-order-service-${local.random_id}"
  retention_in_days = 365
  # ... potentially other configuration ...
}


resource "aws_api_gateway_stage" "order_service_rest_api_stage_2" {
  depends_on = [
    aws_cloudwatch_log_group.order_service_rest_api_log_group
  ]
  rest_api_id   = aws_api_gateway_rest_api.order_service_rest_api.id
  deployment_id = aws_api_gateway_deployment.order_service_rest_api_deployment.id
  stage_name    = var.environment
}


resource "aws_api_gateway_deployment" "order_service_rest_api_deployment" {

  rest_api_id = aws_api_gateway_rest_api.order_service_rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.order_service_rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.order_service_api_proxy_method,
    aws_api_gateway_integration.order_service_rest_api_integration,
    aws_api_gateway_integration.order_service_rest_api_integration_proxy
  ]
}


