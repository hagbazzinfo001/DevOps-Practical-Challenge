output "kops_access_key" {
  value = aws_iam_access_key.kops.id
}

output "kops_secret_key" {
  value     = aws_iam_access_key.kops.secret
  sensitive = true
}
