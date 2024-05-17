resource "aws_ecr_repository" "repo" {
  name                 = "${var.service_name}-ecr"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}

data "aws_ecr_authorization_token" "token" {}

resource "docker_image" "image" {
  name         = aws_ecr_repository.repo.repository_url
  force_remove = true

  build {
    context = "../"
  }

  triggers = {
    "run_always" = timestamp()
  }
}

resource "docker_registry_image" "image" {
  name          = docker_image.image.name
  keep_remotely = true

  triggers = {
    "digest" = docker_image.image.repo_digest
  }
}

# output "docker_image" {
#   value = docker_image.image
# }
# output "docker_registry_image" {
#   value = docker_registry_image.image
# }