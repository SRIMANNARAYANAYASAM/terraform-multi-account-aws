# Name of the SCP to be created
variable "scp_name" {
  type    = string
  default = "DenyDeleteCloudTrail"
}

# Description of the SCP
variable "scp_description" {
  type    = string
  default = "Prevent deletion of CloudTrail logs"
}

# JSON content of the SCP policy
variable "scp_content" {
  type    = string
  default = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "cloudtrail:DeleteTrail",
        "s3:DeleteObject"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

# OU ID of the DevOU to which the SCP will be attached
variable "dev_ou_id" {
  type    = string
  default = "ou-p8d3-z4q2tpyq"
}

# Name of the central S3 bucket for CloudTrail logs
variable "logging_bucket_name" {
  type    = string
  default = "bmahadik-central-logs"
}

# Name of the CloudTrail trail
variable "cloudtrail_name" {
  type    = string
  default = "org-trail"
}

# CloudTrail bucket policy statement block
variable "cloudtrail_bucket_policy_statements" {
  type = any
  default = [
    {
      Sid    = "AWSCloudTrailAclCheck"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:GetBucketAcl"
      Resource = "arn:aws:s3:::bmahadik-central-logs"
    },
    {
      Sid    = "AWSCloudTrailWrite"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "arn:aws:s3:::bmahadik-central-logs/AWSLogs/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" = "bucket-owner-full-control"
        }
      }
    }
  ]
}

