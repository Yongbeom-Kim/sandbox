#!/bin/sh

BASE_DIR=$(pwd)

cd tf
CLOUDFRONT_DIST_ID=$(tofu output -raw cloudfront_distribution_id)
S3_BUCKET_NAME=$(tofu output -raw s3_bucket_name)


cd $BASE_DIR

export AWS_PAGER=""

echo "Invalidating CloudFront cache"
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DIST_ID --paths "/*"

echo "Build vite"
yarn build

echo "Uploading files to S3"
aws s3 cp --recursive ./dist s3://$S3_BUCKET_NAME