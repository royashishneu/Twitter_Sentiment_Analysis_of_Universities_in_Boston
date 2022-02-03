data "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "demo.${var.domain}"
  type    = "A"
  records = [aws_instance.webapp.public_ip]
  ttl     = "300"
}