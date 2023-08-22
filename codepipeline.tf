module "s3_bucket_code_pipeline" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.8.2"

  bucket = "${var.environment}-code-pipeline-bucket-${local.random_id}"
  #  acl           = "private"
  force_destroy     = true
  block_public_acls = true

  versioning = {
    enabled = true
  }


  tags = merge(local.common_tags, {})

}



resource "aws_codepipeline" "microservices_codepipeline" {
  name     = "microservices-code-pipeline"
  role_arn = module.codepipeline_admin_iam_assumable_role.iam_role_arn

  artifact_store {
    location = module.s3_bucket_code_pipeline.s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      run_order        = "1"
      output_artifacts = ["SourceOutput"]
      version          = "1"
      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "msharma24/serverless-microservices"
        BranchName       = "main"
      }

    }
  }


  stage {
    name = "dev-plan"

    action {
      name             = "dev-plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["PlanArtefact"]
      version          = "1"

      configuration = {
        ProjectName          = aws_codebuild_project.tf_plan_microservices_codebuild_project.name
        EnvironmentVariables = <<EOF
            [{ 
                "name": "TF_COMMAND",
                "type": "PLAINTEXT",
                "value": "plan"
            }]
            EOF
      }
    }
  }

  // Disable approval stage for dev

  stage {
    name = "Approval"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        # TODO notification service details
      }
    }
  }

  stage {
    name = "DEV-Apply"

    action {
      name             = "DEV-Apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["ApplyArtefact"]
      version          = "1"

      configuration = {
        ProjectName          = aws_codebuild_project.tf_apply_microservices_codebuild_project.name
        EnvironmentVariables = <<EOF
          [{ 
              "name": "TF_COMMAND",
              "type": "PLAINTEXT",
              "value": "plan"
          }]
          EOF
      }
    }
  }
}



