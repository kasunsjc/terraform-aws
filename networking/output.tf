#----networking/output

output "vpc_id" {
  value = aws_vpc.app_vpc.id
}