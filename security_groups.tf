# security group for the bastion host
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

# security group for the private instance
resource "aws_security_group" "sg_private_instance" {
  name        = "sg_private_instance"
  description = "Allow SSH access from the Bastion Host"
  vpc_id      = aws_vpc.saa_milestone.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_bastion_host.id]
  }

  tags = {
    Name = "SG Private Instance"
  }
  # egress는 필요없음 어짜피 전부 열거니까
}