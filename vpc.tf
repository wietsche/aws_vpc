### VPC ###
### While AWS provides a default VPC for every account, it is recommended to create a custom VPC for your resources.
### We create a VPC with IP range: 10.0.0.0 to 10.0.0.255

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}-vpc"
  }
}

### INTERNERT GATEWAY ###
### Required for resources in the VPC to access the internet.

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.project_name}-igw"
  }
}

### PUBLIC SUBNET ###
### Public subnets are accessible from the internet. We create one, but typically you would create one per availability zone.

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/28" # 10.0.0.0 - 10.0.0.15
  availability_zone = local.az
  tags = {
    Name = "${local.project_name}-public-subnet1"
  }

}

### PUBLIC SUBNET ROUTE TABLE ###
### We route all traffic to the internet gateway. (This may seem insecure but we will add security groups and network ACLs later)

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0" # all traffic
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${local.project_name}-public-route-table"
  }
}

### ASSOCIATE PUBLIC SUBNET WITH ROUTE TABLE ###
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

### PRIVATE SUBNET ###
### We create a private subnet that is not accessible from the internet. Typically you would create one per availability zone.
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.64/28" # 10.0.0.16 - 10.0.0.31
  availability_zone = local.az
  tags = {
    Name = "${local.project_name}-private-subnet1"
  }
}

### NAT GATEWAY ###
### Required for resources in the private subnet to access the internet, but cant be accessed from the internet.

resource "aws_eip" "nat_gateway_ip" {}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id         = aws_subnet.public_subnet1.id
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_gateway_ip.id
}


### PRIVATE SUBNET ROUTE TABLE ###
### We route all traffic to the NAT gateway.

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "${local.project_name}-private-route-table"
  }
}

### ASSOCIATE PRIVATE SUBNET WITH ROUTE TABLE ###
resource "aws_route_table_association" "private_subnet1_association" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}



### CLEAR MAIN ROUTE TABLE ###
### Recommended to clear the default route table of all routes.

resource "aws_default_route_table" "example" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route                  = []
  tags = {
    Name = "empty-default-route-table"
  }
}

### CLEAR DEFAULT SECURITY GROUP ###
### Recommended to clear the default security group of all rules. (Not used in this example)

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "empty-default-security-group"
  }
}

### CLEAR ALL RULES FROM DEFAULT ACL ###
### Recommended to clear the default network ACL of all rules.

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  # no rules defined, deny all traffic in this ACL
  tags = {
    Name = "empty-default-network-acl"
  }
}


### PUBLIC NETWORK ACL ###

resource "aws_network_acl" "public_network_acl" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    rule_no    = 1
    protocol   = "tcp"
    action     = "deny" # best practice, but open during development
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 2
    protocol   = "tcp"
    action     = "deny"
    from_port  = 3389 # RDP, recommended to block
    to_port    = 3389
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 10
    protocol   = "tcp"
    action     = "allow"
    from_port  = 80 # HTTP if running a web server
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }


  ingress {
    rule_no    = 11
    protocol   = "tcp"
    action     = "allow"
    from_port  = 443 # HTTPS if running a web server
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }

  ingress { # required for outgoing internet traffic: https://docs.aws.amazon.com/vpc/latest/userguide/nacl-ephemeral-ports.html
    rule_no    = 12
    protocol   = "tcp"
    action     = "allow"
    from_port  = 32768
    to_port    = 61000
    cidr_block = "0.0.0.0/0"
  }


  egress {
    rule_no  = 100
    protocol = "all"
    action   = "allow"

    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "${local.project_name}-public-network-acl"
  }
}

resource "aws_network_acl_association" "public" {
  network_acl_id = aws_network_acl.public_network_acl.id
  subnet_id      = aws_subnet.public_subnet1.id
}


### PRIVATE NETWORK ACL ###

resource "aws_network_acl" "private_network_acl" {
  vpc_id = aws_vpc.vpc.id

  # block port 22 and 3389 for all traffic
  ingress {
    rule_no    = 1
    protocol   = "tcp"
    action     = "deny"
    from_port  = 22
    to_port    = 22
    cidr_block = "10.0.0.0/28"
  }

  ingress {
    rule_no    = 2
    protocol   = "tcp"
    action     = "deny"
    from_port  = 3389
    to_port    = 3389
    cidr_block = "0.0.0.0/0"
  }

  ingress { # required for outgoing internet traffic: https://docs.aws.amazon.com/vpc/latest/userguide/nacl-ephemeral-ports.html
    rule_no    = 12
    protocol   = "tcp"
    action     = "allow"
    from_port  = 32768
    to_port    = 61000
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    protocol   = "all"
    action     = "allow"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "${local.project_name}-private-network-acl"
  }
}

resource "aws_network_acl_association" "private" {
  network_acl_id = aws_network_acl.private_network_acl.id
  subnet_id      = aws_subnet.private_subnet1.id
}