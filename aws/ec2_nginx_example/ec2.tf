
# AWS Linux 2023 AMI
data "aws_ami" "aws" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-*"]
  }

  filter {
    name   = "owner-id"
    values = ["137112412989"] # Amazon
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.aws.id
  instance_type = "t3.micro"

  associate_public_ip_address = true

  subnet_id = aws_subnet.public.id
  security_groups = [
    aws_security_group.allow_http_https.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_all_outbound.id,
  ]

  user_data = <<-EOT
            #!/bin/bash
            yum update
            yum install -y nginx
            nginx
            EOT

  user_data_replace_on_change = true

  tags = {
    Name = "${var.service_name}-nginx"
  }
}

output "http_ipv4_address" {
  value       = "http://${aws_instance.web.public_ip}"
  description = "The public HTTP ipv4 address of the web server running Nginx."
}