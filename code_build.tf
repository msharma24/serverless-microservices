module "s3_bucket_code_build" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.8.2"

  bucket            = "${var.environment}-code-build-bucket-${local.random_id}"
  force_destroy     = true
  block_public_acls = true

  versioning = {
    enabled = true
  }



}


resource "aws_codebuild_project" "tf_plan_microservices_codebuild_project" {
  name          = "microservices-build-tf-plan-${local.random_id}"
  description   = "microservices lambda build TF Plan pipeline"
  build_timeout = 60
  service_role  = module.codebuild_admin_iam_assumable_role.iam_role_arn

  artifacts {
    #type = "NO_ARTIFACTS"
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "amazonlinux:2"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true


  }

  source {
    #type = "NO_SOURCE"
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/templates/buildspec_plan.yml.tmpl", {
      TF_VERSION = var.terraform_version
    })
  }

  secondary_sources {
    type     = "GITHUB"
    location = "https://github.com/msharma24/serverless-microservices"
    buildspec = templatefile("${path.module}/templates/buildspec_plan.yml.tmpl", {
      TF_VERSION = var.terraform_version
    })
    source_identifier = "grus"
  }

  secondary_source_version {
    source_version    = "main"
    source_identifier = "grus"
  }


  logs_config {
    cloudwatch_logs {
      group_name = module.codebuild_log_group.cloudwatch_log_group_name
    }
  }


  tags = merge(local.common_tags, {})

}



module "codebuild_log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "3.0.0"

  name              = "codebuild_log_group_${random_id.random_id.hex}"
  retention_in_days = 365


  tags = merge(local.common_tags, {})

}




resource "aws_codebuild_project" "tf_apply_microservices_codebuild_project" {
  name          = "microservices-build-tf-apply-${local.random_id}"
  description   = "microservices lambda build TF deploy pipeline"
  build_timeout = 60
  service_role  = module.codebuild_admin_iam_assumable_role.iam_role_arn

  artifacts {
    #type = "NO_ARTIFACTS"
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "amazonlinux:2"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true

  }

  source {
    #type = "NO_SOURCE"
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/templates/buildspec_apply.yml.tmpl", {
      TF_VERSION = var.terraform_version
    })
  }

  secondary_sources {
    type     = "GITHUB"
    location = "https://github.com/msharma24/serverless-microservices"
    buildspec = templatefile("${path.module}/templates/buildspec_apply.yml.tmpl", {
      TF_VERSION = var.terraform_version
    })
    source_identifier = "grus"
  }

  secondary_source_version {
    source_version    = "main"
    source_identifier = "grus"
  }



  logs_config {
    cloudwatch_logs {
      group_name = module.codebuild_log_group.cloudwatch_log_group_name
    }
  }



  tags = merge(local.common_tags, {})

}
