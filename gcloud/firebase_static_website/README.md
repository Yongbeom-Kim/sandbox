# Firebase Terraform Project
Example project using Terraform to host a Vite app on Firebase.

## Dependencies

To get started with this repository, ensure you have the following dependencies installed:
* **Node.js**: required for running the Vite app (I use node v22.8.0 here)
* `make`: for executing Makefile targets
* `opentofu`: for infrastructure management
* `firebase`: for Firebase project management
* `yarn`: for building the Vite app (note: `yarn` is not explicitly listed in `package.json`, but it's implied as the package manager)

## Steps to Deploy

* Set up your environment variables by creating a `.env` file based on the provided `.env.example`

### OpenTofu Project Management

1. Initialize the OpenTofu project: `make tf-init`
2. Plan the OpenTofu project: `make tf-plan`
3. Apply the OpenTofu project: `make tf-apply` (you may have to run this multiple times)
4. Destroy the OpenTofu project (if needed): `make tf-destroy`

### Build and Deploy the Vite App to Firebase

1. Build the Vite app: `make vite-build`
2. Login to Firebase: `make firebase-login`
3. Initialize the Firebase project (if not already done): `make firebase-init`
4. Deploy the Vite app to Firebase: `make firebase-deploy`

## Resources Created

This project utilizes Terraform to manage infrastructure as code (IaC) for a Firebase project. The following resources have been created:

* **Firebase Project**: Configured through `firebase.tf`, this project serves as the foundation for the infrastructure setup.
* **Terraform Provider**: Defined in `provider.tf`, this configuration enables Terraform to interact with Firebase services.
* **Project Configuration**: Specified in `project.tf`, this file contains settings tailored to the project's requirements.

**State Management**:
* `terraform.tfstate`: The primary state file, tracking the current infrastructure configuration.
* `terraform.tfstate.backup`: A backup of the state file, ensuring versioning and recovery capabilities.
* `.terraform.lock.hcl`: Lock file for Terraform, managing dependencies and ensuring consistent deployments.