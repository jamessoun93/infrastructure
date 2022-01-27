# key pair
resource "aws_key_pair" "admin" {
  key_name = "admin"
  public_key = file("~/.ssh/id_rsa.pub")
}

# vpc
resource "aws_vpc" "saa_milestone" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  tags = {
    Name = "saa-milestone"
  }
}

# az
data "aws_availability_zones" "az" { }

# public subnet
resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.saa_milestone.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.az.names[0]

  tags = {
    Name = "public-az-1"
  }
}

# private subnet
resource "aws_subnet" "private_subnet_a" {
  vpc_id = aws_vpc.saa_milestone.id
  cidr_block = "10.0.16.0/20"
  availability_zone = data.aws_availability_zones.az.names[0]

  tags = {
    Name = "private-az-1"
  }
}

# SG for bastion host
# resource "aws_security_group" "sg_bastion_host" {
#   name = "sg_bastion_host"
#   description = "Allow SSH access from anywhere"
#   ingress {
#     from_port = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  # egress는 필요없음 어짜피 전부 열거니까
# }
