variable "project_name" {

  description = "Deploying 2nd tier application on AWS"

}

variable "region" {}
variable "vpc_cidr" {}
variable "pub_sub_1_a_cidr" {}
variable "pub_sub_2_b_cidr" {}
variable "pri_sub_3_a_cidr" {}
variable "pri_sub_4_b_cidr" {}
variable "pri_sub_5_a_cidr" {}
variable "pri_sub_6_b_cidr" {}
variable db_username {}
variable db_password {}
variable certificate_domain_name {}
variable additional_domain_name {}
