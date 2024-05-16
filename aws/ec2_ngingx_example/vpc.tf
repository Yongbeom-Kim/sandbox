# VPC
resource "aws_vpc" "main" {
  cidr_block = "22.0.0.0/16"
}

# Public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "22.0.0.0/24"


  tags = {
    Name = "${var.service_name}-public-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Groups

resource "aws_security_group" "allow_http_https" {
  name        = "${var.service_name}-allow-http-https"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-allow-http-https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.allow_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.service_name}-allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-allow-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_security_group" "allow_all_outbound" {
  name        = "${var.service_name}-allow-all-outbound"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-allow-all-outbound"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.allow_all_outbound.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# TODO: Network ACL
