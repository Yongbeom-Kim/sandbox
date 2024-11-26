# Firebase Frontend + Cloud Run Backend
Example project on how to set up a Frontend (Firebase Hosting) + Backend (Cloud Run) architecture.
## Dependencies

Before you begin, ensure you have the following tools installed and configured on your system:

- **OpenTofu**: Infrastructure as Code tool, installed and available as the `tofu` command.
- **Google Cloud SDK (gcloud CLI)**: Command-line tool for interacting with Google Cloud Platform services.
- **Docker**: For building and running container images.
- **Node.js (I use v22) and Yarn**: Required for building and running the frontend Vite app.
- **Firebase CLI**: Command-line tool for interacting with Firebase services.
- **GNU Make**: For using the provided Makefile scripts.
- **awk**: Used in the `make help` command to display help messages.
- **Environment Variables**: A `.env` file with required environment variables.

**Note**: Ensure that all these tools are installed and properly configured before proceeding.

## Usage

The project uses a Makefile to automate various tasks for setting up, building, and deploying both the frontend and backend applications. The Makefile is organized into categories for ease of use.

To see all available Makefile targets, run:

```sh
make help
```

This will display a list of available commands and their descriptions.

## Overall Scripts

These are high-level scripts that orchestrate multiple tasks.

- **code-setup**: Set up the codebase, including logging into Firebase, initializing Firebase hosting, and configuring Docker.

  ```sh
  make code-setup
  ```

- **code-build**: Build both the frontend and backend code.

  ```sh
  make code-build
  ```

- **code-deploy**: Deploy the backend to Cloud Run and the frontend to Firebase Hosting.

  ```sh
  make code-deploy
  ```

## OpenTofu

Use OpenTofu to manage infrastructure.

- **tf-init**: Initialize the OpenTofu project.

  ```sh
  make tf-init
  ```

- **tf-plan**: Plan the OpenTofu project to see what changes will be made.

  ```sh
  make tf-plan
  ```

- **tf-apply**: Apply the OpenTofu project to create or update infrastructure.

  ```sh
  make tf-apply # You might have to run this multiple times if you get some API errors regarding the GCP Project.
  ```

- **tf-destroy**: Destroy the OpenTofu project infrastructure.

  ```sh
  make tf-destroy
  ```

- **tf-output**: Get a specific output from the OpenTofu project.

  ```sh
  make tf-output OUTPUT_NAME=your_output_name
  ```

## Frontend

Commands related to the frontend application built with Vite.

- **vite-build**: Build the Vite app for production.

  ```sh
  make vite-build
  ```

- **vite-dev**: Run the Vite app in development mode.

  ```sh
  make vite-dev
  ```

- **firebase-login**: Log into Firebase using the Firebase CLI.

  ```sh
  make firebase-login
  ```

- **firebase-init**: Initialize the Firebase project for hosting.

  ```sh
  make firebase-init
  ```

- **firebase-deploy**: Deploy the Vite app to Firebase Hosting.

  ```sh
  make firebase-deploy
  ```

## Backend

Commands related to the backend application.

- **configure-docker**: Configure Docker for use with Google Cloud Container Registry.

  ```sh
  make configure-docker
  ```

- **backend-build**: Build the backend Docker image.

  ```sh
  make backend-build
  ```

- **backend-dev**: Run the backend container in development mode.

  ```sh
  make backend-dev
  ```

- **backend-deploy**: Deploy the backend to Cloud Run.

  ```sh
  make backend-deploy
  ```

- **backend-url**: Get the backend URL from Cloud Run.

  ```sh
  make backend-url
  ```

## Utility

- **help**: Display the help message with available commands.

  ```sh
  make help
  ```

---

### Typical Workflow

1. **Create Environment File**

   Create the `.env` file from the `.env.sample` file to configure environment variables.

   ```sh
   cp .env.sample .env
   # Change the variables to match your project
   ```

2. **Set Up Infrastructure**

   Initialize and apply the OpenTofu project to set up required cloud infrastructure. This will also create the GCP Project.

   ```sh
   make tf-init
   make tf-apply # You might have to run this multiple times if you get some API errors regarding the GCP Project.
   ```

3. **Set Up the Codebase**

   Set up the codebase, including Firebase and Docker configurations.

   ```sh
   make code-setup
   ```

   **Note**: Ensure that you have logged into Firebase and initialized the project.

4. **Build the Applications**

   Build both the frontend and backend applications.

   ```sh
   make code-build
   ```

5. **Deploy the Applications**

   Deploy the backend to Cloud Run and the frontend to Firebase Hosting.

   ```sh
   make code-deploy
   ```

   **Note**: Due to Cloud Run URL changes when deploying the backend, it is important to rebuild and redeploy the frontend after deploying the backend to ensure the frontend uses the correct backend URL.

6. **Running in Development Mode**

   To work on the frontend or backend locally, you can run them in development mode.

   **Frontend Development:**

   ```sh
   make vite-dev
   ```

   **Backend Development:**

   ```sh
   make backend-dev
   ```

# Additional Notes

- **Cloud Run URL Changes**:

  When re-deploying the backend using `gcloud` after deploying via OpenTofu, the Cloud Run URL may change. This can impact the frontend application if it depends on the backend URL. To address this:

  - Retrieve the updated backend URL using:

    ```sh
    make backend-url
    ```

  - Rebuild and redeploy the frontend application to ensure it uses the updated backend URL.

- **Environment Variables**:

  The project relies on environment variables defined in a `.env` file at the project root. This file should include variables such as `TF_VAR_region`, `TF_VAR_backend_repository_id`, `BACKEND_PORT`, and others required by OpenTofu and the applications.

  Ensure that this file is correctly set up before running the Makefile commands.

- **Docker Configuration**:

  The `configure-docker` target uses `gcloud` to configure Docker to authenticate with Google Cloud Container Registry. Ensure that you are authenticated with `gcloud` and have the necessary permissions.

- **Firebase Configuration**:

  The frontend application is deployed to Firebase Hosting. Ensure that you have initialized Firebase in the `frontend` directory and have the appropriate Firebase project set up.

- **Known Issues**:

  - The backend URL is not automatically updated in the OpenTofu state when deploying via `gcloud`. As a result, manual steps are needed to retrieve and update the backend URL in the frontend application.

  - The Cloud Run service may create a new revision with a different URL when re-deploying. Always check the backend URL after deployment.

  - You might have to run `tofu apply` multiple times if you get some API errors regarding the GCP Project.

  - `flask_cors`, for some reason, does not work as expected when running the container on Cloud Run. You have to manually add the CORS headers to the response.
  ```python
  # Does not work
  from flask_cors import CORS
  CORS(app)
  # We use this instead
  @app.after_request
  def add_cors_headers(response):
      response.headers.add('Access-Control-Allow-Origin', '*')
      response.headers.add('Access-Control-Allow-Methods', '*')
      response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
      return response
  ```

- **Help Command**:

  Use `make help` to display all available commands and their descriptions. This can be a quick reference to understand what each Makefile target does.

---

**Reminder**: Always ensure that you have the necessary permissions and that your environment variables are correctly set up before executing the deployment commands. This will help prevent unexpected issues during the deployment process.