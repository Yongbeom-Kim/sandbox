variable "billing_account" {
  description = "The billing account ID that will be associated with the project"
}
variable "project_display_name" {
  description = "The display name of the project"
}

locals {
  project_id = "${var.project_display_name}-${random_id.project_id_suffix.hex}"
}

resource "random_id" "project_id_suffix" {
  byte_length = 6
}


variable "services" {
  type = list(string)
  description = "The services to enable in the project"
  default = [

  ]
}

resource "google_project" "default" {
  name       = var.project_display_name
  project_id = local.project_id
  folder_id = var.folder_id
  billing_account = var.billing_account
  deletion_policy = "DELETE"
}

# Use `gcloud` to enable:
# - serviceusage.googleapis.com
# - cloudresourcemanager.googleapis.com
resource "null_resource" "enable_service_usage_api" {
  provisioner "local-exec" {
    # command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${var.project_id}"
    command = "gcloud services enable serviceusage.googleapis.com --project ${local.project_id}"
  }

  provisioner "local-exec" {
    command = "sleep 15" # Wait for the services to be enabled
  }

  depends_on = [google_project.default]
}

resource "google_project_service" "services" {
  for_each = toset(var.services)

  project = google_project.default.project_id
  service = each.key
  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [null_resource.enable_service_usage_api]
}


# # This gives me debilitating errors
# # I'm not sure why, but I'm not going to spend any more time on this
# # https://github.com/terraform-google-modules/terraform-google-project-factory/issues/813
# module "project-factory" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 17.0"

#   name                 = var.project_display_name
#   folder_id            = var.folder_id
#   random_project_id    = true
#   billing_account      = var.billing_account
#   deletion_policy = "DELETE"
# }