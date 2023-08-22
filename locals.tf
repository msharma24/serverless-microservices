locals {

  env        = var.environment
  region     = data.aws_region.current.id
  account_id = data.aws_caller_identity.current.account_id
  random_id  = random_id.random_id.hex

  # Find the latest Layer version in the official documentation
  # https://awslabs.github.io/aws-lambda-powertools-python/latest/#lambda-layer
  lambda_powertools_layer_arn = "arn:aws:lambda:${local.region}:017000801446:layer:AWSLambdaPowertoolsPythonV2:31"

  # https://docs.aws.amazon.com/systems-manager/latest/userguide/ps-integration-lambda-extensions.html#ps-integration-lambda-extensions-config
  lambda_ssm_params_secrets_layer_arn = "arn:aws:lambda:${local.region}:177933569100:layer:AWS-Parameters-and-Secrets-Lambda-Extension:4"


  common_tags = {
    "ManagedBy"   = "Terraform"
    "Environment" = var.environment

  }

}
