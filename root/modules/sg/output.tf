output "alb_sg_id" {
    value = aws_security_group.alb_sg.id
  
}

output "client_sg_id" {
    value = aws_security_group.client_sg.id
  
}

output "rds_sg_id" {
    value = aws_security_group.rds_sg.id
  
}