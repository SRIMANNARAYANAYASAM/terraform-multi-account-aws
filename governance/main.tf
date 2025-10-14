provider "aws" {
  region = "us-east-2"
}

# Create the SCP
resource "aws_organizations_policy" "deny_delete_cloudtrail" {
  name        = var.scp_name
  description = var.scp_description
  content     = var.scp_content
  type        = "SERVICE_CONTROL_POLICY"
}

# Attach the SCP to the DevOU
resource "aws_organizations_policy_attachment" "attach_to_devou" {
  policy_id = aws_organizations_policy.deny_delete_cloudtrail.id
  target_id = var.dev_ou_id
}

# Create the central S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "central_logging" {
  bucket = var.logging_bucket_name
}

# Attach the required bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail_logging_policy" {
  bucket = aws_s3_bucket.central_logging.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.cloudtrail_bucket_policy_statements
  })
}

# Create the CloudTrail trail
resource "aws_cloudtrail" "org_trail" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.central_logging.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

