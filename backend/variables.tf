# Name of the S3 bucket for Terraform state
variable "state_bucket_name" {
  type        = string
  default     = "bmahadik-terraform-state"
}

# Name of the DynamoDB table for state locking
variable "lock_table_name" {
  type        = string
  default     = "terraform-lock-table"
}

# Owner tag for resource identification
variable "owner" {
  type        = string
  default     = "Bhanudas"
}