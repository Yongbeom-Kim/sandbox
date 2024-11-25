variable "folder_id" {
  description = "The folder ID of the project"
  default = null
}

variable "region" {
  description = "The region to deploy resources"
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.7.0"
    }
  }
}

provider "google" {
  # Configuration options
  region = var.region
  user_project_override = true
}

provider "google-beta" {
  region      = var.region
  user_project_override = true
}
