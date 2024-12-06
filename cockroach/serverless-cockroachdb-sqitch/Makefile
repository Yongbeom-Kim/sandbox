##@ Utility
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Terraform
tf-init: ## Initialize Terraform
	set -a && . ./.env && set +a && cd tf && \
		tofu init

tf-plan: ## Plan Terraform
	set -a && . ./.env && set +a && cd tf && \
		tofu plan

tf-apply: ## Apply Terraform
	set -a && . ./.env && set +a && cd tf && \
		tofu apply

tf-destroy: ## Destroy Terraform
	set -a && . ./.env && set +a && cd tf && \
		tofu destroy

tf-output: ## Get Terraform output
	@set -a && . ./.env && set +a && cd tf && \
		tofu output -raw $(VAR)

COCKROACH_URI=$(shell VAR=cockroach_cluster_connection_uri $(MAKE) -s tf-output)
# COCKROACH_URI=$(shell VAR=cockroach_cluster_connection_uri $(MAKE) -s tf-output | sed 's/postgresql:\/\//pg:\/\//')

print_cockroach_sqitch_uri: ## Print Cockroach URI
	@echo $(COCKROACH_URI) | sed 's/postgresql:\/\//cockroach:\/\//'

print_cockroach_connection_uri: ## Print Cockroach Connection URI
	@VAR=cockroach_cluster_connection_uri $(MAKE) -s tf-output

psql: ## Connect to CockroachDB with psql
	psql $(COCKROACH_URI)
