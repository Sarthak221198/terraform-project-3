# request public certificates from the amazon certificate manager.
# Request a public SSL/TLS certificate from AWS Certificate Manager (ACM)
# - `domain_name`: The primary domain name for which the certificate is requested.
# - `subject_alternative_names`: Additional domain names to be included in the certificate.
# - `validation_method`: Method used to validate the ownership of the domain. Set to "DNS" for DNS validation.
# - `lifecycle`: Ensures the certificate is recreated before deleting the old one if changes are made.
#
# This resource requests a new certificate and specifies DNS validation to prove domain ownership.
resource "aws_acm_certificate" "acm_certificate" {
  domain_name               = var.certificate_domain_name
  subject_alternative_names = [ var.additional_domain_name]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Retrieve details about the Route 53 hosted zone for domain validation
# - `name`: The domain name to look up the hosted zone for.
# - `private_zone`: Set to `false` indicating it's a public hosted zone.
# This data source fetches the hosted zone information that will be used to create DNS records for certificate validation.
data "aws_route53_zone" "route53_zone" {
  name         = var.certificate_domain_name
  private_zone = false
}

# Create a DNS record set in Route 53 for ACM certificate validation.
# This resource creates DNS records required for validating the ACM certificate.
# The records are based on the validation options provided by the ACM certificate.

resource "aws_route53_record" "route53_record" {
  # The `for_each` loop is used to iterate over each domain validation option
  # provided by the ACM certificate. Each domain validation option provides
  # information needed to create a DNS record for validation.
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      # The name of the DNS record to be created, as specified by the ACM certificate.
      name    = dvo.resource_record_name
      # The value of the DNS record to be created, as specified by the ACM certificate.
      record  = dvo.resource_record_value
      # The type of the DNS record (e.g., CNAME, TXT), as specified by the ACM certificate.
      type    = dvo.resource_record_type
      # The hosted zone ID where the DNS record will be created.
      # This will always be the same zone ID because `data.aws_route53_zone.route53_zone.zone_id` is used for all records.
      zone_id = dvo.domain_name == "${var.certificate_domain_name}" ? data.aws_route53_zone.route53_zone.zone_id : data.aws_route53_zone.route53_zone.zone_id
    }
  }
  # Allow overwriting of existing records with the same name.
  allow_overwrite = true
  # The name of the DNS record to be created. This is determined by the `for_each` loop.
  name            = each.value.name
  # The value of the DNS record to be created. This is determined by the `for_each` loop.
  records         = [each.value.record]
  # The time-to-live (TTL) value for the DNS record, specifying how long it should be cached.
  ttl             = 60
  # The type of the DNS record (e.g., CNAME, TXT), determined by the `for_each` loop.
  type            = each.value.type
  # The hosted zone ID where the DNS record will be created, determined by the `for_each` loop.
  zone_id         = each.value.zone_id
}


# Validate the ACM certificate using the DNS records created
# - `certificate_arn`: ARN of the ACM certificate to be validated.
# - `validation_record_fqdns`: List of fully qualified domain names (FQDNs) of the DNS records created for validation.
# This resource completes the validation process by associating the DNS records with the ACM certificate.

# Validate ACM certificates using the DNS records created in Route 53.
# The `for` loop here collects the Fully Qualified Domain Names (FQDNs) of all the DNS records created.
# These FQDNs are used by ACM to validate the certificate.
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}
