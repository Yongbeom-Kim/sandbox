variable "project" {
  type        = string
  description = "The project ID to deploy resources"
}

variable "region" {
  type        = string
  description = "The region to deploy resources"
}

variable "domain" {
  type        = string
  description = "The domain name of the frontend."
  validation {
    condition  = can(regex("[^.]$", var.domain))
    error_message = "The managed zone name must not end with a dot"
  }
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
  region  = var.region
}

provider "google-beta" {
  # Configuration options
  project = var.project
  region  = var.region
}