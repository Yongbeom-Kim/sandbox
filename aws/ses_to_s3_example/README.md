# SES to S3 Example

Example to receive emails (for a Route53 domain) using AWS SES and store them in an S3 bucket.

This project sets up:
- Amazon Simple Email Service
  - Domain Verification
  - Email Receiving Rule Set
    - Email Receiving Rule (to S3 bucket)
  - MX Records for Route53 domain (receiving)
- S3 bucket
  - Bucket Policy (to allow SES to write to the bucket)

Note that this project does not configure SES to send emails (only receive).

## Requirements

* Terraform
* AWS Account
* AWS CLI

## Usage

1. Create a Route53 domain and update the `domain` variable in the `variables.tf` file.
2. Create an S3 bucket and update the `bucket` variable in the `variables.tf` file.
3. Run `terraform init` to initialize the project.
4. Run `terraform apply` to deploy the infrastructure.
5. Update the Route53 domain's MX records with the values of the `mx_records` output.
6. Send an email to `hello@<domain>` and check the S3 bucket for the received email.

## Clean up

Run `terraform destroy` to clean up the infrastructure.