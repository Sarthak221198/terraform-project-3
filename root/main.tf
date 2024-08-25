module "vpc" {
  source           = "./modules/vpc"
  project_name     = var.project_name
  vpc_cidr         = var.vpc_cidr
  pri_sub_3_a_cidr = var.pri_sub_3_a_cidr
  pri_sub_4_b_cidr = var.pri_sub_4_b_cidr
  pri_sub_5_a_cidr = var.pri_sub_5_a_cidr
  pri_sub_6_b_cidr = var.pri_sub_6_b_cidr
  pub_sub_1_a_cidr = var.pub_sub_1_a_cidr
  pub_sub_2_b_cidr = var.pub_sub_2_b_cidr
  region           = var.region
}
# NAT Gateway Module
# - Reusable module for setting up NAT Gateways and associated route tables.
# - Configures NAT Gateways to enable private subnet instances to access the internet.
# VPC ID
# - Passes the VPC ID from the VPC module to the NAT Gateway module.
# Internet Gateway ID
# - Passes the Internet Gateway ID from the VPC module to the NAT Gateway module.
# Private Subnet IDs
# - Passes the IDs of private subnets to the NAT Gateway module for route configuration.
# Public Subnet IDs
# - Passes the IDs of public subnets where NAT Gateways are deployed.
module "nat-gw" {
  source         = "./modules/nat-gw"
  vpc_id         = module.vpc.vpc_id
  igw_id         = module.vpc.igw_id
  pri_sub_3_a_id = module.vpc.pri_sub_3_a_id
  pri_sub_4_b_id = module.vpc.pri_sub_4_b_id
  pri_sub_5_a_id = module.vpc.pri_sub_5_a_id
  pri_sub_6_b_id = module.vpc.pri_sub_6_b_id
  pub_sub_1_a_id = module.vpc.pub_sub_1_a_id
  pub_sub_2_b_id = module.vpc.pub_sub_2_b_id
  region         = var.region
  project_name   = var.project_name
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}
# Key Name
# - Passes the key name for accessing EC2 instances from the key module.
# Target Group ARN
# - Passes the ARN of the target group for load balancing.
# Client Security Group ID
# - Passes the security group ID for clients/EC2 instances.
# Private Subnet IDs
# - Passes the IDs of private subnets for placing Auto Scaling instances.
module "asg" {
  source         = "./modules/auto-sg"
  project_name   = module.vpc.project_name
  key_name       = module.key.key_name
  client_sg_id   = module.sg.client_sg_id
  pri_sub_3_a_id = module.vpc.pri_sub_3_a_id
  pri_sub_4_b_id = module.vpc.pri_sub_4_b_id
  tg_arn         = module.alb.tg_arn

}

module "alb" {
  source         = "./modules/alb"
  project_name   = module.vpc.project_name
  alb_sg_id      = module.sg.alb_sg_id
  pub_sub_1_a_id = module.vpc.pub_sub_1_a_id
  pub_sub_2_b_id = module.vpc.pub_sub_2_b_id
  vpc_id         = module.vpc.vpc_id
  aws_acm_certificate_validation_acm_certificate_validation_arn = module.ACM.aws_acm_certificate_validation_acm_certificate_validation_arn
}

# creating Key for instances
module "key" {
  source = "./modules/key"
}

module "rds" {
  source = "./modules/rds"
  pri_sub_5_a_id = module.vpc.pri_sub_5_a_id
  pri_sub_6_b_id = module.vpc.pri_sub_6_b_id
  db_username = var.db_username
  db_password = var.db_password
  rds_sg_id = module.sg.rds_sg_id
}

#create ssl certificate
module "ACM" {
  source           = "./modules/acm"
  certificate_domain_name      = var.certificate_domain_name
  additional_domain_name = var.additional_domain_name

}



# Add record in route 53 hosted zone

module "route53" {
  source = "./modules/route53"
  aws_lb_application_load_balancer_zone_id = module.alb.alb_zone
  aws_lb_application_load_balancer_dns_name = module.alb.alb_dns_name

}

