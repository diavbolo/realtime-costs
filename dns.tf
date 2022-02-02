
data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false
}

# The domain name to use with api-gateway
resource "aws_api_gateway_domain_name" "api_subdomain" {
  domain_name     = local.api_subdomain_name
  certificate_arn = aws_acm_certificate.api_subdomain.arn
}

resource "aws_route53_record" "api_subdomain" {
  name    = local.api_subdomain_name
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.api_subdomain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api_subdomain.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "api_subdomain" {
  # api-gateway / cloudfront certificates need to use the us-east-1 region
  provider          = aws.cloudfront-acm-certs
  domain_name       = local.api_subdomain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "api_subdomain_validation" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = tolist(aws_acm_certificate.api_subdomain.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.api_subdomain.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.api_subdomain.domain_validation_options)[0].resource_record_value]

  ttl = 60
}

resource "aws_acm_certificate_validation" "api_subdomain_validation" {
  # api-gateway / cloudfront certificates need to use the us-east-1 region
  provider = aws.cloudfront-acm-certs

  certificate_arn         = aws_acm_certificate.api_subdomain.arn
  validation_record_fqdns = [aws_route53_record.api_subdomain_validation.fqdn]

  timeouts {
    create = "45m"
  }
}

resource "aws_acm_certificate" "domain" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "domain" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = tolist(aws_acm_certificate.domain.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.domain.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.domain.domain_validation_options)[0].resource_record_value]
  ttl     = "300"
}

resource "aws_acm_certificate_validation" "domain" {
  certificate_arn = aws_acm_certificate.domain.arn
  validation_record_fqdns = [
    "${aws_route53_record.domain.fqdn}",
  ]
}

resource "aws_route53_record" "es_subdomain" {
  name    = local.es_subdomain_name
  type    = "CNAME"
  zone_id = data.aws_route53_zone.domain.zone_id
  records = [module.elasticsearch.endpoint]
  ttl     = 300
}

resource "aws_route53_record" "mysql_subdomain" {
  name    = local.mysql_subdomain_name
  type    = "CNAME"
  zone_id = data.aws_route53_zone.domain.zone_id
  records = [aws_db_instance.mysql.address]
  ttl     = 300
}

resource "aws_s3_bucket" "mwaa" {
  bucket = local.mwaa_subdomain_name

  website {
    redirect_all_requests_to = "https://${module.mwaa.mwaa_url}"
  }
}

resource "aws_route53_record" "mwaa_subdomain" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = local.mwaa_subdomain_name
  type    = "A"

  alias {
    name                   = aws_s3_bucket.mwaa.website_domain
    zone_id                = aws_s3_bucket.mwaa.hosted_zone_id
    evaluate_target_health = true
  }
}
