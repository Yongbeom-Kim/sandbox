variable "backend_cloud_run_name" {
  description = "The name of the Cloud Run service"
}

variable "backend_port" {
  description = "The port of the backend"
}

resource "google_cloud_run_v2_service" "default" {
  project  = var.project_id
  name     = var.backend_cloud_run_name
  location = var.region

  template {
    containers {
      image = "nginx:alpine"
      ports {
        container_port = 80 # Needed for nginx
      }
    }
  }
  deletion_protection = false
}

resource "google_project_organization_policy" "allowed_policy_member_domains" {
  project = var.project_id
  constraint = "constraints/iam.allowedPolicyMemberDomains"

  list_policy {
    allow { all = true }
  }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
  project  = var.project_id
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"

  depends_on = [google_project_organization_policy.allowed_policy_member_domains]
}