variable "cluster_name" {
    type = string
}

variable "regions" {
    type = list(object({
        name       = string
        node_count = optional(number)
        primary    = optional(bool)
    }))
}

variable "cockroach_version" {
    type = string
}

resource "cockroach_cluster" "example" {
    name = var.cluster_name
    cloud_provider = "AWS"
    regions = var.regions
    serverless = {}
    cockroach_version = var.cockroach_version
}

resource "random_id" "sql_user_name" {
    byte_length = 8
}

resource "random_password" "sql_user_password" {
    length = 16
    special = false
}

resource "cockroach_sql_user" "example" {
    name = random_id.sql_user_name.hex
    password = random_password.sql_user_password.result
    cluster_id = cockroach_cluster.example.id
}

output "cockroach_cluster_connection_uri" {
    value = "postgresql://${random_id.sql_user_name.hex}:${random_password.sql_user_password.result}@${cockroach_cluster.example.regions[0].sql_dns}:26257/defaultdb?sslmode=verify-full"
    sensitive = true
}
