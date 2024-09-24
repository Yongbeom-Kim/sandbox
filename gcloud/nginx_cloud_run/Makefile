deploy:
	. ./source.sh && \
		cd tf && \
		tofu init && \
		tofu apply -auto-approve

destroy:
	. ./source.sh && \
		cd tf && \
		tofu destroy -auto-approve

url:
	. ./source.sh && \
		cd tf && \
		tofu output
