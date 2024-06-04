# S3 bucket for upload
resource "aws_s3_bucket" "upload" {
  bucket_prefix = "${var.service_name}-bucket"
  force_destroy = true # This is a dangerous option, use with caution. Convenient for this example.
}

resource "aws_s3_bucket_cors_configuration" "upload" {
  bucket = aws_s3_bucket.upload.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
    # Expose the Etag header to the client
    expose_headers = ["Etag"]
  }
}

# IAM policy for uploading to the bucket. This user should ideally live in the backend service.
data "aws_iam_policy_document" "upload" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.upload.arn}",
      "${aws_s3_bucket.upload.arn}/*",
    ]
  }
}

resource "aws_iam_user" "upload" {
  name = "${var.service_name}-backend"
}

resource "aws_iam_user_policy" "upload" {
  name = "${var.service_name}-upload-policy"
  user = aws_iam_user.upload.name
  policy = data.aws_iam_policy_document.upload.json
}


resource "aws_iam_access_key" "upload" {
  user = aws_iam_user.upload.name
}

output "upload_user_access_key" {
  value = aws_iam_access_key.upload.id
  sensitive = true
}

output "upload_user_secret_key" {
  value = aws_iam_access_key.upload.secret
  sensitive = true
}

output "upload_bucket" {
  value = aws_s3_bucket.upload.bucket
}
