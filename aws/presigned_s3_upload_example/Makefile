init plan apply destroy:
	cd opentofu && tofu $@


serve:
	@ VITE_IAM_USER=$(shell cd opentofu && tofu output -raw upload_user_access_key) \
		VITE_IAM_KEY=$(shell cd opentofu && tofu output -raw upload_user_secret_key) \
		yarn run dev