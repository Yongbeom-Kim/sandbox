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

## Set up S3
resource "aws_s3_bucket" "inbox" {
  bucket_prefix = "${var.service_name}-inbox"
  # Easy and convenient, probably disable in production.
  force_destroy = true

  tags = {
    Name = "${var.service_name}-inbox"
  }
}