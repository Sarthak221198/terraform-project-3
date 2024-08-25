# Outputs
# - Outputs important information after resource creation.
# - Useful for referencing these values in other modules or scripts.

output "region" {
  value = var.region
}

output "project_name" {
  value = var.project_name
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "pub_sub_1_a_id" {
  value = aws_subnet.pub-sub-1a.id
}

output "pub_sub_2_b_id" {
  value = aws_subnet.pub-sub-2b.id
}

output "pri_sub_3_a_id" {
  value = aws_subnet.pri-sub-3a.id
}

output "pri_sub_4_b_id" {
  value = aws_subnet.pri-sub-4b.id
}

output "pri_sub_5_a_id" {
  value = aws_subnet.pri-sub-5a.id
}

output "pri_sub_6_b_id" {
  value = aws_subnet.pri-sub-6b.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}
