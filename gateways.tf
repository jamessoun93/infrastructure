# elastic ip
resource "aws_eip" "eip_nat_gateway" {
  vpc = true
}

# internet gateway
resource "aws_internet_gateway" "igw_saa_milestone" {
  vpc_id = aws_vpc.saa_milestone.id

  tags = {
    Name = "IGW SAA Milestone"
  }
}

# nat gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id     = aws_eip.eip_nat_gateway.id
  subnet_id         = aws_subnet.public_subnet_a.id
  connectivity_type = "public"

  tags = {
    Name = "NATGW SAA Milestone"
  }
}