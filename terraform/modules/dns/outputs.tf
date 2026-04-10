output "zone_id" {
  description = "The Hosted Zone ID in Route53"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The Name Servers for delegation"
  value       = aws_route53_zone.main.name_servers
}
