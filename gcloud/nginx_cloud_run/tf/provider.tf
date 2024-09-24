variable "project" {
  type = string
  description = "Name of the project. This value should be shared within the entire repository."
}

variable "region" {
  type = string
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.3.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = var.project

  region = var.region

  default_labels = {
    "managed-by"  = "opentofu"
    "project"     = var.project
    # "environment" = "production" # TODO: This depends on the environment/branch.
  }
}