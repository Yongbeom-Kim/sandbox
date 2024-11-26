# AWS Sandbox

Sandbox for examples and testing with Google Cloud services. All examples are written in Terraform/OpenTofu.

## Sub-Repositories

| Sub-repository | Description |
| --- | --- |
| [./cloud_storage_static_website_example](./cloud_storage_static_website_example) | This is an example of how to host a static website (Vite template) on Google Cloud Storage, with the relevant DNS, SSL, and CDN/Load Balancer configurations. |
| [./firebase_static_website](./firebase_static_website) | Example project using Terraform to host a Vite app on Firebase. |
| [./firebase_website_cloud_run_backend](./firebase_website_cloud_run_backend) | Example project on how to set up a Frontend (Firebase Hosting) + Backend (Cloud Run) architecture. |
| [./nginx_cloud_run](./nginx_cloud_run) | This is an example of how to deploy an Nginx container to Cloud Run. |