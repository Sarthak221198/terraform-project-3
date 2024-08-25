variable "pri_sub_5_a_id" {}
variable "pri_sub_6_b_id" {}
variable "db_sub_name" {
    default = "book-shop-db-subnet-a-b"
}
variable db_username {}
variable db_password {}
variable "db_name" {
    default = "testdb"
}
variable "rds_sg_id" {}