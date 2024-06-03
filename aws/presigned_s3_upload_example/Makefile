init plan apply destroy:
	cd opentofu && tofu $@


serve:
	@ VITE_IAM_USER=$(shell cd opentofu && tofu output -raw upload_user_access_key) \
		VITE_IAM_KEY=$(shell cd opentofu && tofu output -raw upload_user_secret_key) \
		VITE_UPLOAD_BUCKET=$(shell cd opentofu && tofu output -raw upload_bucket) \
		VITE_AWS_REGION=$(shell cd opentofu && tofu output -raw aws_region) \
		yarn run dev