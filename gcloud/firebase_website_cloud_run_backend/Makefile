##@ Utility
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

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

##@ Frontend
vite-build:  ## Build the Vite app
	cd frontend && yarn && yarn run build

firebase-login:  ## Login to Firebase
	cd frontend && firebase login

firebase-init:  ## Initialize the Firebase project
	cd frontend && firebase init hosting

firebase-deploy:  ## Deploy the Vite app to Firebase
	cd frontend && firebase deploy --only hosting
