# Creates S3 bucket to store remote Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket        = var.state_bucket_name
  force_destroy = true

  tags = {
    Name  = "Terraform State Bucket"
    Owner = var.owner
  }
}

# Enables versioning for rollback and audit
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypts state files at rest using AES256
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Creates DynamoDB table for state locking to prevent concurrent applies
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name  = "Terraform Lock Table"
    Owner = var.owner
  }
}