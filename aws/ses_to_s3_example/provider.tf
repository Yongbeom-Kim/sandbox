terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
  }
}

provider "aws" {
  # Configuration options
  default_tags {
    tags = {
      Service   = var.service_name
      Name      = "${var.service_name}-resource"
      ManagedBy = "Terraform"
    }
  }
}

variable "domain" {
  type        = string
  description = "The domain name for the email address of the service. This domain must be registered in Amazon Route 53."
}

variable "service_name" {
  type        = string
  description = "The name of the service, used as a prefix for all resource names."
}