
module "elasticsearch" {
  source  = "lgallard/elasticsearch/aws"
  version = "0.12.2"

  domain_name           = local.es_name
  elasticsearch_version = "7.10"

  cluster_config = {
    dedicated_master_enabled = false
    instance_count           = var.es_instance_count
    instance_type            = var.es_instance
    zone_awareness_enabled   = false
    availability_zone_count  = 2
  }

  ebs_options = {
    ebs_enabled = "true"
    volume_size = var.es_storage
  }

  encrypt_at_rest = {
    enabled = true
  }

  log_publishing_options = {
    index_slow_logs = {
      enabled                          = true
      cloudwatch_log_group_arn         = "${aws_cloudwatch_log_group.log_publishing_options.arn}:*"
      log_publishing_options_retention = 90
    }

    search_slow_logs = {
      enabled                  = true
      cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.search_slow_logs.arn}:*"
    }

    es_application_logs = {
      enabled                   = true
      cloudwatch_log_group_name = "${local.es_name}_application"
    }

    audit_logs = {
      enabled                   = false
      cloudwatch_log_group_name = "${local.es_name}_audit"
    }
  }

  domain_endpoint_options = {
    enforce_https                   = true
    custom_endpoint_enabled         = true
    custom_endpoint                 = local.es_subdomain_name
    custom_endpoint_certificate_arn = aws_acm_certificate.domain.arn
  }

  advanced_options = {
    "override_main_response_version"         = "false"
    "rest.action.multi.allow_explicit_index" = "true"
  }

  node_to_node_encryption_enabled                = true
  snapshot_options_automated_snapshot_start_hour = 23

  advanced_security_options_master_user_username = var.es_user
  advanced_security_options_master_user_password = random_password.es_creds.result

  advanced_security_options_internal_user_database_enabled = true

  advanced_security_options = {
    enabled = true
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${local.es_name}/*"
    }
  ]
}
  CONFIG

}

resource "aws_cloudwatch_log_group" "search_slow_logs" {
  name = "/aws/elasticsearch/search_slow_logs"
}

resource "aws_cloudwatch_log_group" "log_publishing_options" {
  name = "/aws/elasticsearch/log_publishing_options"
}

resource "random_password" "es_creds" {
  length           = 10
  special          = true
  override_special = "@"
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  min_lower        = 1
}

resource "aws_secretsmanager_secret" "es_creds" {
  name = "${local.secrets_name}/elasticsearch/credentials"
}

resource "aws_secretsmanager_secret_version" "es_creds" {
  secret_id     = aws_secretsmanager_secret.es_creds.id
  secret_string = <<EOF
   {
    "username": "${var.es_user}",
    "password": "${random_password.es_creds.result}"
   }
EOF
}

data "aws_secretsmanager_secret" "es_creds" {
  arn = aws_secretsmanager_secret.es_creds.arn
}

data "aws_secretsmanager_secret_version" "es_creds" {
  secret_id = data.aws_secretsmanager_secret.es_creds.arn
}
