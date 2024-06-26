variable "s3_inbox_key_prefix" {
  type        = string
  description = "The prefix for the S3 object key when messages are added to the S3 bucket."
  default = null
}

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

## Set up SES to receive emails
# Route53 MX record
resource "aws_route53_record" "ses_mx" {
  zone_id = data.aws_route53_zone.main.id
  name    = aws_ses_domain_identity.main.domain
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${data.aws_region.current.name}.amazonaws.com"]
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

locals {
  ses_receipt_rule_name = "${var.service_name}-rule"
}

data "aws_iam_policy_document" "allow_ses_access" {
  statement {
    sid = "AllowSESPuts"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    actions = ["s3:PutObject"]
    # Even if we have a prefix, we need to allow access to all items inside the bucket, or else the rule creation will fail.
    resources = ["${aws_s3_bucket.inbox.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      # This is the ARN of the receipt rule set
      # The receipt rule can only be created after the bucket policy, so we use a local variable for this.
      # Note that we cannot use the ARN of the receipt rule itself, as it is not created yet.
      # We also cannot use something like :receipt-rule/* for some reason (it fails??)
      values   = ["${aws_ses_receipt_rule_set.main.arn}:receipt-rule/${local.ses_receipt_rule_name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_ses_access" {
  bucket = aws_s3_bucket.inbox.id
  policy = data.aws_iam_policy_document.allow_ses_access.json
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "${var.service_name}-rule-set"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}

resource "aws_ses_receipt_rule" "ses_to_s3" {
  name          = "${local.ses_receipt_rule_name}"
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
    object_key_prefix = var.s3_inbox_key_prefix
    position    = 2
  }

  # Cannot be added until the bucket policy is created
  depends_on = [ aws_s3_bucket_policy.allow_ses_access ]
}

## Set up SES to send emails
resource "aws_ses_domain_mail_from" "main" {
  domain = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.main.domain}"
}

# MX record
resource "aws_route53_record" "example_ses_domain_mail_from_mx" {
  zone_id = data.aws_route53_zone.main.id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

# SPF TXT record
resource "aws_route53_record" "example_ses_domain_mail_from_txt" {
  zone_id = data.aws_route53_zone.main.id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

# DKIM record
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_route53_record" "dkim_records" {
  count   = 3
  zone_id = data.aws_route53_zone.main.id
  name    = "${aws_ses_domain_dkim.main.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.main.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

# DMARC TXT record
resource "aws_route53_record" "dmarc_record" {
  zone_id = data.aws_route53_zone.main.id
  name    = "_dmarc.${aws_ses_domain_mail_from.main.mail_from_domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=reject; rua=mailto:admin@${var.domain}"]
}

# SMTP Credentials
resource "aws_iam_user" "smtp_user" {
  name = "${var.service_name}-smtp-user"
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["${aws_ses_domain_identity.main.arn}"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "${var.service_name}-ses-sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "smtp_user" {
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

locals {
  smtp_username = aws_iam_access_key.smtp_user.id
  smtp_password = aws_iam_access_key.smtp_user.ses_smtp_password_v4
}
