# public subnet
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.saa_milestone.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]

  tags = {
    Name = "Public AZ 1 (A)"
  }
}

# private subnet
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.saa_milestone.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = data.aws_availability_zones.az.names[0]

  tags = {
    Name = "Private AZ 1 (A)"
  }
}