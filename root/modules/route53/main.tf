# Retrieve the details of a Route 53 public hosted zone
# This data source queries Route 53 to find a public hosted zone with the specified name.
# The `name` attribute is used to match the hosted zone in Route 53.
# The `private_zone` attribute is set to `false` to indicate that we are looking for a public hosted zone.
data "aws_route53_zone" "public-zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

# Create an A record in Route 53 for an Application Load Balancer (ALB)
# This resource creates an A record in the specified Route 53 hosted zone.
# The `zone_id` is obtained from the `data.aws_route53_zone.public-zone` data source, which identifies the hosted zone where the record will be created.
# The `name` attribute specifies the DNS name for the A record, which is typically the domain name for which you're setting up the ALB.
# The `type` attribute is set to "A" to create an A record, which maps the domain name to the ALB's IP address.
# The `alias` block is used to set up an alias record that points to the ALB.
# - `name`: The DNS name of the ALB, which is obtained from the ALB's DNS name.
# - `zone_id`: The hosted zone ID of the ALB, which is used to route traffic to the correct target.
# - `evaluate_target_health`: This attribute indicates whether Route 53 should evaluate the health of the ALB when routing traffic. Set to `false` to skip health checks.
resource "aws_route53_record" "example" {
  zone_id = data.aws_route53_zone.public-zone.zone_id
  name    = var.hosted_zone_name
  type    = "A"

  alias {
    name                   = var.aws_lb_application_load_balancer_dns_name
    zone_id                = var.aws_lb_application_load_balancer_zone_id
    evaluate_target_health = false
  }
}