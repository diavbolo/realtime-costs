output "mwaa_arn" {
  value = aws_mwaa_environment.this.arn
}

output "mwaa_url" {
  value = aws_mwaa_environment.this.webserver_url
}

output "mwaa_role" {
  value = aws_iam_role.this.arn
}
