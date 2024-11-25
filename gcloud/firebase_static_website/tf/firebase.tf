variable "firebase_site_id" {
  description = "The Firebase site ID"
}

resource "google_firebase_project" "default" {
  provider = google-beta
  project  = google_project.default.project_id
}

# This is actually not necessary
# resource "google_firebase_hosting_site" "default" {
#   provider = google-beta
#   project = google_firebase_project.default.project
#   site_id = var.firebase_site_id
# }