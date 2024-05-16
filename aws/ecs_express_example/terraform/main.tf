terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "aws" {
  # Configuration options
  default_tags {
    tags = {
      "ManagedBy" = "Terraform"
      "Name"      = "${var.service_name}-service"
    }
  }
}

provider "docker" {
  # Configuration options
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password

  }
}

variable "service_name" {
  type = string
}