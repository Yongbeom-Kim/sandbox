## Set up SES
data "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

resource "aws_route53_record" "ses_verification" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

resource "aws_ses_domain_identity_verification" "main" {
  domain = aws_ses_domain_identity.main.id

  depends_on = [aws_route53_record.ses_verification]
}

# Route53 MX record
resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.main.domain}"
}

resource "aws_route53_record" "ses_mx" {
  zone_id = data.aws_route53_zone.main.id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"] # Change to the region in which `aws_ses_domain_identity.example` is created
}

# TODO: Need SPF and DKIM records

## Set up S3
resource "aws_s3_bucket" "inbox" {
  bucket_prefix = "${var.service_name}-inbox"
  # Easy and convenient, probably disable in production.
  force_destroy = true

  tags = {
    Name = "${var.service_name}-inbox"
  }
}

# Bucket policy to allow SES to write to the bucket
data "aws_iam_policy_document" "allow_s3_access" {
  statement {
    sid = "AllowSESPuts"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    actions = ["s3:PutObject"]
    resources = [aws_s3_bucket.inbox.arn, "${aws_s3_bucket.inbox.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      # This is the ARN of the receipt rule set
      # The receipt rule can only be created after the bucket policy, so we need to use a wildcard for now
      values   = ["${aws_ses_receipt_rule_set.main.arn}:receipt-rule/*"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_s3_access" {
  bucket = aws_s3_bucket.inbox.id
  policy = data.aws_iam_policy_document.allow_s3_access.json
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "${var.service_name}-rule-set"
}

resource "aws_ses_receipt_rule" "ses_to_s3" {
  name          = "${var.service_name}-rule"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  recipients    = ["${var.domain}"]
  enabled       = true
  scan_enabled  = true
  tls_policy    = "Require"

  add_header_action {
    header_name  = "X-SES-${var.service_name}"
    header_value = "This email was processed by SES and stored in S3. Service: ${var.service_name}"
    position     = 1
  }

  s3_action {
    bucket_name = aws_s3_bucket.inbox.bucket
    position    = 2
  }

  # Cannot be added until the bucket policy is created
  depends_on = [ aws_s3_bucket_policy.allow_s3_access ]
}