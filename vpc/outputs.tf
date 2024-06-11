output "fp_vpc_id" {
  value = aws_vpc.fp_vpc.id
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.pub_sub : subnet.id]
}
