# key pair
resource "aws_key_pair" "admin" {
  key_name   = "admin"
  public_key = file("~/.ssh/id_rsa.pub")
}

# vpc
resource "aws_vpc" "saa_milestone" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "SAA Milestone"
  }
}

# az
data "aws_availability_zones" "az" { }

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

# internet gateway
resource "aws_internet_gateway" "igw_saa_milestone" {
  vpc_id = aws_vpc.saa_milestone.id

  tags = {
    Name = "IGW SAA Milestone"
  }
}

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

# security group for bastion host
resource "aws_security_group" "sg_bastion_host" {
  name        = "sg_bastion_host"
  description = "Allow SSH access from anywhere"
  vpc_id      = aws_vpc.saa_milestone.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG Bastion Host"
  }
  # egress는 필요없음 어짜피 전부 열거니까
}

data "aws_ami" "amazon_linux_2_ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220121.0-x86_64-gp2"]
  }
}

# bastion host (EC2)
resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.amazon_linux_2_ami.id
  instance_type               = "t2.micro"
  availability_zone           = aws_subnet.public_subnet_a.availability_zone
  key_name                    = aws_key_pair.admin.key_name
  vpc_security_group_ids      = [aws_security_group.sg_bastion_host.id]
  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true

  tags = {
    Name = "Bastion Host"
  }
}