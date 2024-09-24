#!/bin/bash
set -a
. ./.env

GOOGLE_APPLICATION_CREDENTIALS="$(realpath .)/gcloud_auth/config.json"
gcloud auth activate-service-account --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

set +a