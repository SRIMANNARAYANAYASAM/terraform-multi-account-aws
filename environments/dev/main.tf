# Deploys VPC using reusable module and aliased provider
module "dev_vpc" {
  source     = "../../modules/vpc"
  providers  = { aws = aws.member }
  cidr_block = var.cidr_block
  name       = var.name
}