# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet pub-sub-1-a
resource "aws_eip" "EIP-NAT-GW-A" {
  domain = "vpc"

  tags   = {
    Name = "NAT-GW-EIP-A"
  }
}
# allocate elastic ip. this eip will be used for the nat-gateway in the public subnet pub-sub-2-b
resource "aws_eip" "EIP-NAT-GW-B" {
  domain    = "vpc"

  tags   = {
    Name = "NAT-GW-EIP-B"
  }
}

# NAT Gateway A
# - Creates a NAT Gateway in the public subnet pub-sub-1-a using the allocated EIP.
# - Depends on the Internet Gateway to ensure proper ordering.
resource "aws_nat_gateway" "NAT-GW-A" {
  allocation_id = aws_eip.EIP-NAT-GW-A.id
  subnet_id     = var.pub_sub_1_a_id

  tags   = {
    Name = "NAT-GW-A"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  depends_on = [var.igw_id]
}

# create nat gateway in public subnet pub-sub-1-a
resource "aws_nat_gateway" "NAT-GW-B" {
  allocation_id = aws_eip.EIP-NAT-GW-B.id
  subnet_id     = var.pub_sub_2_b_id

  tags   = {
    Name = "NAT-GW-B"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  # on the internet gateway for the vpc.
  depends_on = [var.igw_id]
}

# create private route table Pri-RT-A and add route through NAT-GW-A
resource "aws_route_table" "Pri-RT-A" {
  vpc_id            = var.vpc_id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.NAT-GW-A.id
  }

  tags   = {
    Name = "Pri-RT-A"
  }
}

# associate private subnet pri-sub-3-a with private route table Pri-RT-A
resource "aws_route_table_association" "pri-sub-3-a-with-Pri-RT-A" {
  subnet_id         = var.pri_sub_3_a_id
  route_table_id    = aws_route_table.Pri-RT-A.id
}

resource "aws_route_table_association" "pri-sub-4-b-with-Pri-RT-B" {
  subnet_id         = var.pri_sub_5_a_id
  route_table_id    = aws_route_table.Pri-RT-A.id
}

resource "aws_route_table" "Pri-RT-B" {
  vpc_id            = var.vpc_id

  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.NAT-GW-B.id
  }

  tags   = {
    Name = "Pri-RT-B"
  }
}

# associate private subnet pri-sub-4-b with private route Pri-RT-B
resource "aws_route_table_association" "pri-sub-5-a-with-Pri-RT-B" {
  subnet_id         = var.pri_sub_4_b_id
  route_table_id    = aws_route_table.Pri-RT-B.id
}

# associate private subnet pri-sub-6-b with private route table Pri-RT-B
resource "aws_route_table_association" "pri-sub-6-b-with-Pri-RT-B" {
  subnet_id         = var.pri_sub_6_b_id
  route_table_id    = aws_route_table.Pri-RT-B.id
}