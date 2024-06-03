# S3 bucket for upload
resource "aws_s3_bucket" "upload" {
  bucket_prefix = "${var.service_name}-bucket"
  force_destroy = true # This is a dangerous option, use with caution. Convenient for this example.
}

# IAM policy for uploading to the bucket. This user should ideally live in the backend service.
data "aws_iam_policy_document" "upload" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      # "s3:ListBucket",
      # "s3:DeleteObject",
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