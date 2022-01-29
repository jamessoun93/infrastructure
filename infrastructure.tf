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

# resource "aws_internet_gateway" "igw_saa_milestone" {
#   vpc_id = aws_vpc.saa_milestone.id

#   tags = {
#     Name = "IGW SAA Milestone"
#   }
# }

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