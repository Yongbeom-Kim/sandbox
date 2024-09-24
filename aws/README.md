# AWS Sandbox

Sandbox for examples and testing with AWS services. All examples are written in Terraform/OpenTofu.

## Sub-Repositories

| Sub-repository | Description |
| --- | --- |
| [./ec2_nginx_example](./ec2_nginx_example) | Installation of Nginx on EC2 instance. Example for configuring VPCs, subnets, security groups to host web applications on EC2 instances. |
| [./ecs_express_example](./ecs_express_example) | Sample project to demonstrate how to deploy an Express.js application to AWS ECS. |
| [./presigned_s3_upload_example](./presigned_s3_upload_example) | This is a simple example of how to upload files to an S3 bucket using presigned URLs (both single and multi-part). |
| [./s3_website_example](./s3_website_example) | This is an example of how to host a static website on S3. This example uses terraform to create the S3 bucket, enable static website hosting, and upload the website files, with configuration of a CloudFront distribution + Route53 domain to serve the website. |
| [./ses_to_s3_example](./ses_to_s3_example) | Example to receive emails (for a Route53 domain) using AWS SES and store them in an S3 bucket. |.