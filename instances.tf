data "aws_ami" "amazon_linux_2_ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220121.0-x86_64-gp2"]
  }
}

# bastion host (EC2)
resource "aws_instance" "bastion_host_a" {
  ami                         = data.aws_ami.amazon_linux_2_ami.id
  instance_type               = "t2.micro"
  availability_zone           = aws_subnet.public_subnet_a.availability_zone
  key_name                    = "admin"
  vpc_security_group_ids      = [aws_security_group.sg_bastion_host.id]
  subnet_id                   = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true
  user_data                   = file("ec2_init.sh")

  tags = {
    Name = "Bastion Host A"
  }
}

# private instance (EC2)
resource "aws_instance" "private_ec2_instance_a" {
  ami                    = data.aws_ami.amazon_linux_2_ami.id
  instance_type          = "t2.micro"
  availability_zone      = aws_subnet.private_subnet_a.availability_zone
  key_name               = "admin"
  vpc_security_group_ids = [aws_security_group.sg_private_instance.id]
  subnet_id              = aws_subnet.private_subnet_a.id
  user_data              = file("ec2_init.sh")

  tags = {
    Name = "Private Instance A"
  }
}