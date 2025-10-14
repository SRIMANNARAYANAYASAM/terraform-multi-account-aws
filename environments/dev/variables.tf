# CIDR block for the VPC
variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
}

# Name tag for the VPC
variable "name" {
  type        = string
  default     = "dev-vpc"
}

# IAM role ARN to assume into dev-member account
variable "dev_role_arn" {
  type        = string
  default     = "arn:aws:iam::<dev-account-id>:role/OrganizationAccountAccessRole"
}
