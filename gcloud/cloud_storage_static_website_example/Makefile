SHELL=/bin/bash
.PHONY: build deploy deploy_infra deploy_code destroy destroy_infra

build:
	yarn
	yarn run build

deploy: deploy_infra deploy_code

destroy: destroy_infra

deploy_infra:
	. ./source.sh && \
		cd tf && \
		tofu init && \
		tofu apply -auto-approve

deploy_code: build
	. ./source.sh && \
		yarn && \
		yarn run build && \
		gsutil -m rm -r gs://$${TF_VAR_frontend_bucket_name}/* || true && \
		gsutil -m cp -r dist/* gs://$${TF_VAR_frontend_bucket_name}



destroy_infra:
	. ./source.sh && \
		cd tf && \
		tofu init && \
		tofu destroy -auto-approve