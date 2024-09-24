#!/bin/bash

set -a

. ./.env

TF_VAR_frontend_bucket_name=$(printf ${TF_VAR_frontend_bucket_name} | grep -oE -m 1 '^[a-zA-Z0-9-]{0,40}[a-zA-Z0-9]' | tail -n 1 )

GOOGLE_APPLICATION_CREDENTIALS="$(realpath .)/gcloud_auth/config.json"
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

set +a