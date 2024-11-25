variable "billing_account" {
  description = "The billing account ID that will be associated with the project"
}
variable "project_display_name" {
  description = "The display name of the project"
}
variable "firebase_site_id" {
  description = "The Firebase site ID"
}

module "project" {
  source = "./project"
  billing_account = var.billing_account
  project_display_name = var.project_display_name
  folder_id = var.folder_id
}


module "frontend" {
  source = "./frontend"
  project_id = module.project.project_id
  firebase_site_id = var.firebase_site_id
}