# Input CIDR block for the VPC
variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

# Input name tag for the VPC
variable "name" {
  type        = string
  description = "Name tag for the VPC"
}