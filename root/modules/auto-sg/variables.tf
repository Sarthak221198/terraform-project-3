variable "project_name" {
  
}

variable "ami"{
    default = "ami-04a81a99f5ec58529"
}

variable "instance_type"{
    default = "t2.micro"
}

variable "key_name"{

}

variable "client_sg_id"{

}

variable "max_size" {
    default = 6
}
variable "min_size" {
    default = 2
}
variable "desired_cap" {
    default = 3
}
variable "asg_health_check_type" {
    default = "ELB"
}
variable "pri_sub_3_a_id" {}
variable "pri_sub_4_b_id" {}
variable "tg_arn" {}