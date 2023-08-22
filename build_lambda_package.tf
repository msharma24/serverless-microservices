# Create zip-archive of a single directory where "pip install" will also be executed (default for python runtime with requirements.txt present)
module "user_service_lambda_package" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.2.0"

  create_function = false
  #recreate_missing_package = false

  build_in_docker = true
  runtime         = "python3.9"
  source_path = [{
    path             = "${path.module}/lambda/UserService/"
    pip_requirements = true
  }]
  artifacts_dir = "${path.root}/builds/package_dir/"

}

output "user_service_lambda_package_file_name" {
  value = module.user_service_lambda_package.local_filename
}


module "order_service_lambda_package" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.2.0"

  create_function = false
  #recreate_missing_package = false

  build_in_docker = true
  runtime         = "python3.9"
  source_path = [{
    path             = "${path.module}/lambda/OrderService"
    pip_requirements = true
  }]
  artifacts_dir = "${path.root}/builds/package_dir/"

}

output "order_service_lambda_package_file_name" {
  value = module.order_service_lambda_package.local_filename
}

