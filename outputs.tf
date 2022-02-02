
output "mysql_url" {
  value = aws_route53_record.mysql_subdomain.name
}

output "es_url" {
  value = aws_route53_record.es_subdomain.name
}

output "kibana_url" {
  value = "https://${aws_route53_record.es_subdomain.name}/_plugin/kibana/"
}

output "mwaa_url" {
  value = "http://${aws_route53_record.mwaa_subdomain.name}"
}

output "api_url" {
  value = "https://${aws_api_gateway_base_path_mapping.api.domain_name}/${aws_api_gateway_resource.readwriteResource.path_part}"
}

output "sns_notification_arn" {
  value = aws_sns_topic.sns_alert.arn
}

output "sns_notification_role_arn" {
  value = aws_iam_role.sns_alert.arn
}

output "kibana_user" {
  value = var.es_user
}

output "kibana_password" {
  value = nonsensitive(random_password.es_creds.result)
}

output "mwaa_role" {
  value = module.mwaa.mwaa_role
}

output "bucket_airflow_name" {
  value = "s3://${aws_s3_bucket.s3_bucket_airflow.bucket}"
}

output "bucket_data_name" {
  value = "s3://${aws_s3_bucket.s3_bucket_costs.bucket}"
}
