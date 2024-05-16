variable "service_name" {
  type        = string
  description = "The name of the service used as a prefix for all resources and their names."
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }
}

provider "aws" {
  # Configuration options
  default_tags {
    tags = {
      Service   = var.service_name
      ManagedBy = "Terraform"
      Name      = "${var.service_name}"
      name      = "${var.service_name}"
    }
  }
}
