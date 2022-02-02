
locals {
  secrets_name = "${var.project_name}-secrets"
}

locals {
  git_name = "${var.project_name}-git"
}

locals {
  backup_name = "${var.project_name}-backup"
}

locals {
  dynamodb_name = "${var.project_name}-dynamodb"
}

locals {
  lambda_name = "${var.project_name}-lambda"
}

locals {
  mysql_name = "${var.project_name}-mysql"
}

locals {
  crawler_name = "${var.project_name}-crawler"
}

locals {
  glue_name = "${var.project_name}-glue"
}

# Glue catalog name cannot use hyphen character
locals {
  glue_db_name = replace("${var.project_name}-db", "-", "_")
}

locals {
  es_name = "${var.project_name}-es"
}

locals {
  kinesis_ec2_name = "${var.project_name}-ec2"
}

locals {
  kinesis_ec2_enriched_name = "${var.project_name}-ec2-enriched"
}

locals {
  kinesis_studio_name = "${var.project_name}-kinesis-studio"
}

locals {
  airflow_name = "${var.project_name}-airflow"
}

locals {
  cloudtrail_name = "${var.project_name}-cloudtrail"
}

locals {
  sns_name = "${var.project_name}-alert"
}

locals {
  api_subdomain_name = "api.${var.domain_name}"
}

locals {
  es_subdomain_name = "es.${var.domain_name}"
}

locals {
  mysql_subdomain_name = "mysql.${var.domain_name}"
}

locals {
  mwaa_subdomain_name = "airflow.${var.domain_name}"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.db_creds.secret_string
  )
}

locals {
  es_creds = jsondecode(
    data.aws_secretsmanager_secret_version.es_creds.secret_string
  )
}
