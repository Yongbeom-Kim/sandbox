variable "region" {
  description = "The region of the project"
}

variable "project_id" {
  description = "The project ID"
}

variable "backend_repository_id" {
  description = "The repository ID of the backend"
}

resource "google_artifact_registry_repository" "backend" {
  location      = var.region
  project       = var.project_id
  repository_id = var.backend_repository_id
  description   = "Backend Docker repository"
  format        = "DOCKER"
}