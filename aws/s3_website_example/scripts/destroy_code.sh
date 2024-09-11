#!/bin/sh

BASE_DIR=$(pwd)

cd tf
CLOUDFRONT_DIST_ID=$(tofu output -raw cloudfront_distribution_id)
S3_BUCKET_NAME=$(tofu output -raw s3_bucket_name)


cd $BASE_DIR

export AWS_PAGER=""

aws s3 rm s3://$S3_BUCKET_NAME --recursive