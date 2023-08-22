variable "aws_region" {
  type    = string
  default = "us-east-1"

}

variable "environment" {
  description = "AWS environment"
  type        = string
  default     = "dev"

}

variable "terraform_version" {
  default = "1.5.3"
}

variable "github_connection_arn" {
  default = "arn:aws:codestar-connections:us-east-1:923529015425:connection/787c2b29-3246-4af2-87d7-42b7f166eaa1"
}
