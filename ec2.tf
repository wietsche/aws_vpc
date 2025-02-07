# Security group
resource "aws_security_group" "jump_host" {
  name        = "${local.project_name}-instance"
  description = "Security group for the jump host instance"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "host_egress" {
  security_group_id = aws_security_group.jump_host.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}


# allow 443 traffic from anywhere
resource "aws_security_group_rule" "host_ingress80" {
  security_group_id = aws_security_group.jump_host.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

# allow 80 traffic from anywhere
resource "aws_security_group_rule" "host_ingress443" {
  security_group_id = aws_security_group.jump_host.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}


# allow port 22 from anywhere
resource "aws_security_group_rule" "host_ingress22" {
  security_group_id = aws_security_group.jump_host.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}
# t2.micro instance

resource "tls_private_key" "ec2_host" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jump_host" {
  key_name   = "local.project_name-key"
  public_key = tls_private_key.ec2_host.public_key_openssh
}

resource "local_file" "jump_host_private_key" {
  filename        = "${local.project_name}-key.pem"
  file_permission = "0400"
  content         = tls_private_key.ec2_host.private_key_pem
}


data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# serves a static page
locals {
  jump_host_user_data = <<EOF
#!/bin/bash
sudo su
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
chown -R $USER /var/www/html
echo "<h1>Hello World</h1>" > /var/www/html/index.html
EOF
}

resource "aws_instance" "host_public" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.jump_host.id]
  key_name                    = aws_key_pair.jump_host.key_name
  user_data                   = local.jump_host_user_data
  user_data_replace_on_change = true
  associate_public_ip_address = true
  tags = {
    Name = "host_public"
  }
}

# launch the same instance in the private subnet, will have outbound internet access, not inbound
resource "aws_instance" "jump_hot_private" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet1.id
  vpc_security_group_ids      = [aws_security_group.jump_host.id] # for brevity, we use the same security group but should adjust this to be more restrictive
  key_name                    = aws_key_pair.jump_host.key_name
  user_data                   = local.jump_host_user_data
  user_data_replace_on_change = true
  associate_public_ip_address = true
  tags = {
    Name = "host_private"
  }
}