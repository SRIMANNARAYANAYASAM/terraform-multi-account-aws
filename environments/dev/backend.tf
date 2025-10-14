# Configures remote backend to use central S3 and DynamoDB
terraform {
  backend "s3" {
    bucket         = "bmahadik-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}