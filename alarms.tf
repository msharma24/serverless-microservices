module "monitoring_sns_topic" {
  source  = "terraform-aws-modules/sns/aws"
  version = "5.3.0"

  name = "serverless-monitoring-sns-${local.random_id}"
  subscriptions = {
    email = {
      protocol = "email"
      endpoint = "mukeshsharma24@gmail.com"
    }
  }

}

output "monitoring_sns_topic_arn" {
  value = module.monitoring_sns_topic.topic_arn

}


#---------------------------------------------------------
# Lambda Logs Error Monitoring
#---------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "user_service_lambda_error" {
  name = "user_service_lambda_error"

  log_group_name = module.user_service_lambda_function.lambda_cloudwatch_log_group_name
  pattern        = "?ERROR ?Error ?error"

  metric_transformation {
    name      = "user_service_lambda_error"
    namespace = "user_service_lambda"
    value     = "1"
  }

}


resource "aws_cloudwatch_log_metric_filter" "order_service_lambda_error" {
  name           = "submit_order_service_lambda_error"
  log_group_name = module.order_service_lambda_function.lambda_cloudwatch_log_group_name
  pattern        = "?ERROR ?Error ?error"
  metric_transformation {
    name      = "order_service_lambda_error"
    namespace = "order_service_lambda"
    value     = "1"
  }

}


resource "aws_cloudwatch_metric_alarm" "user_service_lambda_error_alarm" {
  alarm_name          = "user_service_lambda_error_alarm"
  alarm_description   = "[INFO] Error during lambda execution - Check Cloudwatch Logs for user_service_lambda function"
  metric_name         = aws_cloudwatch_log_metric_filter.user_service_lambda_error.name
  threshold           = 0
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "user_service_lambda"
  alarm_actions = [

    module.monitoring_sns_topic.topic_arn
  ]

}



resource "aws_cloudwatch_metric_alarm" "order_service_lambda_error_alarm" {
  alarm_name          = "order_service_lambda_error_alarm"
  alarm_description   = "[INFO] Error during lambda execution - Check Cloudwatch Logs for order_service_lambda Lambda function"
  metric_name         = aws_cloudwatch_log_metric_filter.order_service_lambda_error.name
  threshold           = 0
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "order_service_lambda"
  alarm_actions = [

    module.monitoring_sns_topic.topic_arn
  ]

}



