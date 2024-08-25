# VPC (Virtual Private Cloud)
# - Creates a VPC with the specified CIDR block.
# - Enables DNS support and hostnames.
# - Tags the VPC with a project-specific name.
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
# - Attaches an Internet Gateway to the VPC.
# - Enables outbound internet access.
# - Tags the gateway with the project name.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Availability Zones
# - Fetches a list of available AWS availability zones in the region.
data "aws_availability_zones" "available_zones" {}

# Public Subnets
# - Creates public subnets in specified availability zones.
# - Automatically assigns public IPs to instances.
# - Tags the subnets with descriptive names.
resource "aws_subnet" "pub-sub-1a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pub_sub_1_a_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "pub-sub-1a"
  }
}

resource "aws_subnet" "pub-sub-2b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pub_sub_2_b_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "pub-sub-2b"
  }
}

# Route Table for Public Subnets
# - Creates a route table with a default route to the Internet Gateway.
# - Associates public subnets with the route table to enable internet access.
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "pub_sub_1a_route_table_association" {
  subnet_id = aws_subnet.pub-sub-1a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "pub_sub_2b_route_table_association" {
  subnet_id = aws_subnet.pub-sub-2b.id
  route_table_id = aws_route_table.public-rt.id
}

# Private Subnets
# - Creates private subnets in specified availability zones.
# - Instances in these subnets do not get public IPs.
# - Tags the subnets with descriptive names.
resource "aws_subnet" "pri-sub-3a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pri_sub_3_a_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub-3-a"
  }
}

resource "aws_subnet" "pri-sub-4b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pri_sub_4_b_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub-4-b"
  }
}

resource "aws_subnet" "pri-sub-5a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pri_sub_5_a_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub-5-a"
  }
}

resource "aws_subnet" "pri-sub-6b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pri_sub_6_b_cidr
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub-6-b"
  }
}
