terraform {
  required_providers {
    cockroach = {
      source = "cockroachdb/cockroach"
      version = "1.10.0"
    }
  }
}

provider "cockroach" {
  # Configuration options
}