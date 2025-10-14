# Outputs the VPC ID for use in other modules or environments
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}