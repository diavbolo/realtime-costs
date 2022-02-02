
# This is the main variable name and used as a prefix for all assets (see locals.tf)
variable "project_name" {
  default = "realtime-costs"
}

# Manually create this domain in Route53
variable "domain_name" {
  default = "realtime-costs.com"
}

# AWS region 
variable "region" {
  default = "eu-west-1"
}

# AWS region for the S3 replica bucket
variable "region_replica" {
  default = "us-west-1"
}

# S3 data bucket
variable "bucket_data_name" {
  default = "realtime-costs-data"
}

# S3 replica data bucket
variable "bucket_data_replica_name" {
  default = "realtime-costs-data-replica"
}

# S3 Airflow bucket
variable "bucket_airflow_name" {
  default = "realtime-costs-airflow"
}

# Email for notifications
variable "sns_notification" {
  default = "diego@doit-intl.com"
}

# GitHub repo where the Airflow DAGs are placed
variable "airflow_git_repository" {
  default = "diavbolo/realtime-costs-airflow"
}

# Main repository branch
variable "airflow_git_branch" {
  default = "master"
}

# VPC network
variable "vpc_subnet" {
  default = "172.31.0.0/16"
}

# First 2 subnets are for Glue, Kinesis Data Studio and MySQL. The remainings are for MWAA
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["172.31.32.0/20", "172.31.16.0/20", "172.31.64.0/20", "172.31.80.0/20"]
}

# First 2 subnets are for Glue, Kinesis Data Studio and MySQL. The remainings are for MWAA
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["172.31.128.0/20", "172.31.144.0/20", "172.31.96.0/20", "172.31.112.0/20"]
}

#
# No need to change from this point
#

variable "bucket_folder_ec2_costs" {
  default = "ec2_costs"
}

variable "bucket_folder_ec2_streams" {
  default = "ec2_streams"
}

variable "bucket_folder_ec2_streams_errors" {
  default = "ec2_streams_errors"
}

variable "ec2_streams_schema_name" {
  default = "ec2_streams_schema"
}

variable "mysql_user" {
  default = "admin"
}

variable "mysql_instance" {
  default = "db.t3.micro"
}

variable "mysql_storage" {
  default = 20
}

variable "mysql_db_name" {
  default = "db"
}

variable "mysql_table_name" {
  default = "ec2_costs"
}

variable "es_user" {
  default = "root"
}

variable "es_ec2_index_name" {
  default = "ec2"
}

variable "es_instance" {
  default = "t3.small.elasticsearch"
}

variable "es_instance_count" {
  default = "2"
}

variable "es_storage" {
  default = 25
}

variable "api_stage" {
  default = "prod"
}
