.PHONY: help tf-init tf-plan tf-apply tf-destroy tf-output code-setup code-build code-deploy vite-build vite-dev firebase-login firebase-init firebase-deploy backend-build backend-dev backend-deploy backend-url

##@ Utility
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


PROJECT_ID=$(shell make -s tf-output OUTPUT_NAME=project_id)
BACKEND_URL=$(shell make -s backend-url)

##@ OpenTofu
tf-init:  ## Initialize the OpenTofu project
	set -a && source ./.env && set +a && \
		cd tf && tofu init

tf-plan:  ## Plan the OpenTofu project
	set -a && source ./.env && set +a && \
		cd tf && tofu plan

tf-apply:  ## Apply the OpenTofu project
	set -a && source ./.env && set +a && \
		cd tf && tofu apply

tf-destroy:  ## Destroy the OpenTofu project
	set -a && source ./.env && set +a && \
		cd tf && tofu destroy

tf-output:  ## Get a specific output from the OpenTofu project. Usage: make tf-output OUTPUT_NAME=project_id
	@set -a && source ./.env && set +a && \
		cd tf && tofu output -raw $${OUTPUT_NAME}

##@ Overall Scripts
code-setup:  ## Setup the codebase
	$(MAKE) firebase-login
	$(MAKE) firebase-init
	$(MAKE) configure-docker

code-build:  ## Build the codebase
	$(MAKE) backend-build
	$(MAKE) vite-build

code-deploy:  ## Deploy the codebase
	$(MAKE) backend-deploy
# Because the Cloud Run URL changes when re-deploying over gcloud after terraform.
	$(MAKE) vite-build
	$(MAKE) firebase-deploy

##@ Frontend
vite-build:  ## Build the Vite app
	cd frontend && \
		yarn && \
		export VITE_BACKEND_URL=$(BACKEND_URL) && \
		yarn run build

vite-dev:  ## Run the Vite app in dev mode
	cd frontend && \
		yarn && \
		export VITE_BACKEND_URL=$(BACKEND_URL) && \
		yarn run dev

firebase-login:  ## Login to Firebase
	cd frontend && firebase login

firebase-init:  ## Initialize the Firebase project
	cd frontend && firebase init hosting

firebase-deploy:  ## Deploy the Vite app to Firebase
	cd frontend && firebase deploy --only hosting

##@ Backend
configure-docker:  ## Configure Docker
	set -a && source ./.env && set +a && \
		gcloud auth configure-docker $${TF_VAR_region}-docker.pkg.dev

backend-build:  ## Build the backend
	set -a && source ./.env && set +a && \
		cd backend && \
		docker build \
			-t $${TF_VAR_region}-docker.pkg.dev/$(PROJECT_ID)/$${TF_VAR_backend_repository_id}/backend:latest \
			--build-arg BACKEND_PORT=$${BACKEND_PORT} \
			.
backend-dev:  ## Run the backend container in dev mode
	set -a && source ./.env && set +a && \
		docker run \
			-p 7000:$${BACKEND_PORT} \
			$${TF_VAR_region}-docker.pkg.dev/$(PROJECT_ID)/$${TF_VAR_backend_repository_id}/backend:latest	

## You would think this would work, but it doesn't.
## For some reason, updating the Cloud run service from terraform, then gcloud creates a new revision with a DIFFERENT url.
backend-deploy:  ## Deploy the backend
	set -a && source ./.env && set +a && \
		cd backend && \
		docker push $${TF_VAR_region}-docker.pkg.dev/$(PROJECT_ID)/$${TF_VAR_backend_repository_id}/backend:latest && \
		gcloud run deploy $${TF_VAR_backend_cloud_run_name} \
			--project $(PROJECT_ID) \
			--port $${BACKEND_PORT} \
			--region $${TF_VAR_region} \
			--image $${TF_VAR_region}-docker.pkg.dev/$(PROJECT_ID)/$${TF_VAR_backend_repository_id}/backend:latest \
			--allow-unauthenticated

# This is a hack to get the backend URL.
# It's not ideal, but it works for now.
# This happens because the Cloud Run URL changes when re-deploying over gcloud after terraform.
# The URL is not updated in the terraform state, so terraform can't know the new URL.
# The URL also cannot be gotten from looking at the Cloud Run service status, as it is not updated there either.
# This is the simplest way to get the new URL.
backend-url:  ## Get the backend URL
	@set -a && source ./.env && set +a && \
		gcloud run services describe $${TF_VAR_backend_cloud_run_name} --project $(PROJECT_ID) --region $${TF_VAR_region} --format json | grep -Eo 'https://[^"]+.run.app' | head -n 1
