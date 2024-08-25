# Security Group for the ALB (Application Load Balancer)
# - Allows HTTP and HTTPS access to the ALB on ports 80 and 443.
# - Permits all outbound traffic.
resource "aws_security_group" "alb_sg" {
    name = "alb security group"
    description = "allow http/https access on port 80/443"
    vpc_id = var.vpc_id
  
    ingress  {
        description = "http access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress  {
        description = "https access"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]       
    }
    tags = {
        Name = "alb_sg"
    }

}
# Security Group for Clients/EC2 Instances
# - Allows HTTP and HTTPS access on ports 80 and 443 only from the ALB security group.
# - Permits all outbound traffic.
resource "aws_security_group" "client_sg" {
    name = "clients security group"
    description = "allow http/https access on port 80 from the alb"
    vpc_id = var.vpc_id
  
    ingress  {
        description = "http access"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups =  [aws_security_group.alb_sg.id]
    }
    ingress  {
        description = "https access"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_groups =  [aws_security_group.alb_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]       
    }
    tags = {
        Name = "client_sg"
    }

}

# Security Group for RDS Instances
# - Allows MySQL access on port 3306 only from the Client security group.
# - Permits all outbound traffic.
resource "aws_security_group" "rds_sg" {
    name = "client security group"
    description = "enable mysql access on port 3305 from client-sg"
    vpc_id = var.vpc_id
  
    ingress  {
        description = "rds access"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        security_groups =  [aws_security_group.client_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]       
    }
    tags = {
        Name = "rds_sg"
    }

}