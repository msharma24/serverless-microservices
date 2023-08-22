module "dynamodb_stream_lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.3.0"

  function_name = "${var.environment}-cdc-lambda"
  description   = "Dynamodb Stream to Custom Eventbridge Lambda function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  create_role   = true

  create_current_version_allowed_triggers = false


  memory_size = "128"
  #  timeout     = "60"

  #create_async_event_config    = true
  #maximum_event_age_in_seconds = 100

  attach_policies    = true
  attach_policy_json = true
  policy_json        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ssm:GetParameter",
              "kms:Decrypt",
              "events:PutEvents",
              "sqs:*",
              "dynamodb:GetRecords",
              "dynamodb:GetShardIterator",
              "dynamodb:DescribeStream",
              "dynamodb:ListStreams"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF


  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole",
  ]

  source_path = "./lambda/DynamodbStreamLambda/lambda_function.py"

  layers = [
    local.lambda_powertools_layer_arn,
  ]


  number_of_policies = 1



  environment_variables = {
    environment             = var.environment
    POWERTOOLS_SERVICE_NAME = "DynamodbStreamLambda"
    SNS_TOPIC_ARN           = module.monitoring_sns_topic.topic_arn
  }

  tags = {
    Name = "${var.environment}-Lambda"

  }


}
