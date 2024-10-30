output "aws_vpc" {
  value = aws_vpc.vpc
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnets_id" {
  value = aws_subnet.private_subnet[*].id
}