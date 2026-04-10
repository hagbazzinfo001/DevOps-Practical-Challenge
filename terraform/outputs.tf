output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "name_servers_to_delegate" {
  description = "You MUST configure these NS records with your domain registrar"
  value       = module.dns.name_servers
}

output "kops_iam_user_access_key_id" {
  sensitive = true
  value     = module.iam.kops_access_key
}

output "kops_iam_user_secret_access_key" {
  sensitive = true
  value     = module.iam.kops_secret_key
}
