#--------------------------------------------------------------------------
# EB Pipes IAM role
#--------------------------------------------------------------------------
module "eb_pipe_iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.9.2"

  trusted_role_services = [
    "pipes.amazonaws.com"
  ]

  role_requires_mfa       = false
  create_role             = true
  create_instance_profile = true

  role_name = "eb-pipe-role-${local.random_id}"

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess"

  ]
}

output "eb_pipe_iam_assumable_role" {
  value = module.eb_pipe_iam_assumable_role.iam_role_arn

}


#--------------------------------------------------------------------------
# CodeBuild IAM role
#--------------------------------------------------------------------------
module "codebuild_admin_iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.5"

  trusted_role_services = [
    "codebuild.amazonaws.com"
  ]

  role_requires_mfa       = false
  create_role             = true
  create_instance_profile = true

  role_name = "codebuild-admin-role-${local.random_id}"

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    aws_iam_policy.codepipeline_custom_policy.arn
  ]
}

#--------------------------------------------------------------------------
# CodePipeline IAM role
#--------------------------------------------------------------------------
module "codepipeline_admin_iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.5"

  trusted_role_services = [
    "codepipeline.amazonaws.com"
  ]

  role_requires_mfa       = false
  create_role             = true
  create_instance_profile = true

  role_name = "codepipeline-admin-role-${local.random_id}"

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    aws_iam_policy.codepipeline_custom_policy.arn

  ]
}


resource "aws_iam_policy" "codepipeline_custom_policy" {
  name        = "codepipeline-custom-policy-${random_id.random_id.hex}"
  path        = "/"
  description = "Codepipeline custom IAM Policy"

  depends_on = [
    module.codepipeline_admin_iam_assumable_role.id
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:*",
          "codebuild:*",
          "codedeploy:*",
          "codestar-connections:UseConnection",
          "codestar:*",
          "cloudwatch:*",
          "ec2:*",
          "dynamodb:*",
          "iam:*",
          "apigateway:*",
          "rds:*",
          "ssm:*",
          "acm:*",
          "codepipeline:*",
          "route53:*",
          "lambda:*",
          "elasticfilesystem:*",
          "quicksight:*",
          "backup:*"

        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#--------------------------------------------------------------------------
