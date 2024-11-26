variable "billing_account" {
  description = "The billing account ID that will be associated with the project"
}
variable "project_display_name" {
  description = "The display name of the project"
}
variable "firebase_site_id" {
  description = "The Firebase site ID"
}

variable "backend_repository_id" {
  description = "The repository ID of the backend"
}

variable "backend_cloud_run_name" {
  description = "The name of the Cloud Run service"
}

variable "backend_port" {
  description = "The port of the backend"
}

module "project" {
  source = "./project"
  billing_account = var.billing_account
  project_display_name = var.project_display_name
  folder_id = var.folder_id
  services = [
    "firebase.googleapis.com",
    "artifactregistry.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}


module "frontend" {
  source = "./frontend"
  project_id = module.project.project_id
  firebase_site_id = var.firebase_site_id
}

module "backend" {
  source = "./backend"
  region = var.region
  project_id = module.project.project_id
  backend_repository_id = var.backend_repository_id
  backend_cloud_run_name = var.backend_cloud_run_name
  backend_port = var.backend_port
}

output "project_id" {
  value = module.project.project_id
}