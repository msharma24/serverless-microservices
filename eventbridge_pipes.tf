locals {
  eventbrige_iam = module.eb_pipe_iam_assumable_role.iam_role_arn
}

resource "aws_pipes_pipe" "aws_pipes_pipe" {

  name     = "ddb-eb-pipe"
  role_arn = local.eventbrige_iam
  source   = aws_dynamodb_table.ecommerce_table.stream_arn
  target   = module.dynamodb_stream_lambda_function.lambda_function_arn

  source_parameters {

    dynamodb_stream_parameters {
      starting_position = "LATEST"

    }
  }

  # target_parameters {
  #   input_template = <<-EOT
  #       {
  #         "eventID": <$.eventID>,
  #         "eventName": <$.eventName>,
  #         "OrderPlaced": <$.dynamodb.NewImage.Status>,
  #         "OrderId": <$.dynamodb.NewImage.OrderId>,
  #         "NumberItems": <$.dynamodb.NewImage.NumberItems>,
  #         "NumberItems": <$.dynamodb.NewImage.PK>
  #
  #
  #
  #       }
  #   EOT
  # }



}
