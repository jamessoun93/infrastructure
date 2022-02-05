# route table (public)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.saa_milestone.id

  tags = {
    Name = "Public Route Table"
  }
}

# route table (private)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.saa_milestone.id

  tags = {
    Name = "Private Route Table"
  }
}

# route table association (public)
resource "aws_route_table_association" "public_route_table_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

# route table association (private)
resource "aws_route_table_association" "private_route_table_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

// 아래 기본 route는 필요없음
// 참고) default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.
# resource "aws_route" "public_route_a" {
#   route_table_id         = aws_route_table.public_route_table.id
#   destination_cidr_block = "10.0.0.0/16"
# }

resource "aws_route" "public_route_b" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_saa_milestone.id
}

resource "aws_route" "private_route_b" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway.id
}