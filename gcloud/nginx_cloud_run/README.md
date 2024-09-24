# Nginx Cloud Run Example
This is an example of how to deploy an Nginx container to Cloud Run.

To access the Nginx container, visit the Cloud Run service URL: [directed-timing-436615-k6-nginx-cloud-run-ekvmnyolta-uc.a.run.app](https://directed-timing-436615-k6-nginx-cloud-run-ekvmnyolta-uc.a.run.app)
## Prerequisites
- Google Cloud SDK (`gcloud` CLI)
- OpenTofu
- Yarn

## Deploying
Here are the pre-Terraform steps:
1. Create a Google Cloud project.
2. Create a service account with the relevant permissions (Storage Admin, DNS Admin, etc.) and download the JSON key.
3. Copy the JSON key to `./gcloud_auth/config.json`

To deploy the Nginx container to Cloud Run, run the following commands:
```bash
make deploy
```

To destroy the Cloud Run service, run the following commands:
```bash
make destroy
```

To get the Cloud Run service URL, run the following command:
```bash
make url
```

This Cloud Run service can be used as a precursor to deploying a Cloud Run with a proper web service (treat the Nginx container as a dummy service).

## License