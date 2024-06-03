terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.52.0"
    }
  }
}

provider "aws" {
  # Configuration options
  default_tags {
    tags = {
        ManagedBy = "Terraform/OpenTofu"
        Service = var.service_name
        Name = "${var.service_name}"
    }
  }
}

variable "service_name" {
    type = string
    default = "my-service"
    description = "Service name used as a prefix for all resource names."
}

data "aws_region" "current" {}

output "aws_region" {
    value = data.aws_region.current.name
}