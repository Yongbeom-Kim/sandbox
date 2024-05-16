# Nginx on EC2

Installation of Nginx on EC2 instance. Example for configuring VPCs, subnets, security groups to host web applications on EC2 instances.

## Prerequisites
- AWS CLI
- Terraform

## Steps
1. Authenticate AWS CLI
2. `terraform init`
3. `terraform plan`
4. `terraform apply`
5. There will be an output with the public IP of the EC2 instance. Use this IP to access the Nginx server after some delay (HTTP only).

To destroy the infrastructure, do `terraform destroy`.

## Notes
This project configures the following infrastructure:
- A VPC
- A (public) subnet
  - Internet gateway & Route table for subnet
  - EC2 instance
    - Security groups for EC2 instance (Incoming HTTP(S), Incoming SSH, Outgoing all)