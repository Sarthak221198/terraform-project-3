# Create an AWS RDS DB Subnet Group
# - `name`: Sets the name of the subnet group, defined by the variable `db_sub_name`.
# - `subnet_ids`: Specifies the subnets where the RDS instances will be deployed. These subnets should be in different Availability Zones for high availability.
# - `tags`: Tags to help identify and organize the subnet group.
# This subnet group allows the RDS instance to be placed in the specified private subnets.
resource "aws_db_subnet_group" "db-subnet" {
  name       = var.db_sub_name
  subnet_ids = [var.pri_sub_6_b_id, var.pri_sub_5_a_id]

  tags = {
    Name = "My DB subnet group"
  } 
}
# Create an AWS RDS DB Instance
# - `identifier`: Unique name for the RDS instance.
# - `engine`: Specifies the database engine to use. Here it's MySQL.
# - `engine_version`: The version of the MySQL engine to use.
# - `instance_class`: Defines the instance type (e.g., `db.t3.micro`), which determines the instance's resources.
# - `allocated_storage`: Amount of storage allocated to the instance in gigabytes.
# - `username` and `password`: Credentials for the database administrator. Both are defined by variables.
# - `db_name`: The name of the initial database to create.
# - `multi_az`: Set to `true` to enable Multi-AZ deployments for high availability.
# - `storage_type`: Specifies the type of storage. `gp2` refers to General Purpose SSD.
# - `storage_encrypted`: Indicates whether storage encryption is enabled. Set to `false` here.
# - `publicly_accessible`: Determines if the instance is accessible from the internet. Set to `false` for security.
# - `skip_final_snapshot`: Set to `true` to skip taking a final snapshot before deleting the instance.
# - `backup_retention_period`: Set to `0` to disable backups.
# - `vpc_security_group_ids`: List of security group IDs to apply to the RDS instance. Use the RDS security group ID here.
# - `db_subnet_group_name`: References the subnet group created earlier to specify where the RDS instance should be deployed.
# - `tags`: Tags to help identify and organize the RDS instance.
#
# This RDS instance is configured for high availability and is placed within the specified private subnets with security group restrictions.

resource "aws_db_instance" "db" {
  identifier              = "bookdb-instance"
  engine                  = "mysql"
  engine_version          = "5.7.44"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  multi_az                = true
  storage_type            = "gp2"
  storage_encrypted       = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  vpc_security_group_ids = [var.rds_sg_id] # Replace with your desired security group ID

  db_subnet_group_name = aws_db_subnet_group.db-subnet.name

  tags = {
    Name = "bookdb"
  }
}