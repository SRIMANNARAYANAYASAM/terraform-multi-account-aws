# AWS provider that assumes role into dev-member account
provider "aws" {
  alias  = "member"
  region = "us-east-2"

  # Assumes cross-account IAM role from management account
  assume_role {
    role_arn = var.dev_role_arn
  }
}