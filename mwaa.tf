
module "mwaa" {
  source = "./modules/terraform-aws-mwaa"

  account_id            = data.aws_caller_identity.current.account_id
  environment_name      = aws_s3_bucket.s3_bucket_airflow.bucket
  internet_gateway_id   = aws_internet_gateway.public_network.id
  private_subnet_cidrs  = [var.private_subnet_cidrs[2], var.private_subnet_cidrs[3]]
  public_subnet_cidrs   = [var.public_subnet_cidrs[2], var.public_subnet_cidrs[3]]
  region                = var.region
  source_bucket_arn     = aws_s3_bucket.s3_bucket_airflow.arn
  vpc_id                = aws_vpc.main.id
  webserver_access_mode = "PUBLIC_ONLY"
  requirements_s3_path  = aws_s3_bucket_object.mwaa_copy_requirements.key
  additional_execution_role_policy_document_json = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "kinesis:Describe*",
            "kinesis:Get*",
            "kinesis:List*",
            "kinesis:Put*",
            "kinesis:SubscribeToShard",
          ],
          "Resource" : [
            "${aws_kinesis_stream.kinesis.arn}",
            "${aws_kinesis_stream.kinesis.arn}/*",
            "${aws_kinesis_stream.kinesis_enriched.arn}",
            "${aws_kinesis_stream.kinesis_enriched.arn}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:Get*",
            "s3:Put*"
          ],
          "Resource" : [
            "${aws_s3_bucket.data.arn}",
            "${aws_s3_bucket.data.arn}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "glue:GetDatabase*",
            "glue:GetTable*",
            "glue:GetPartitions",
            "glue:GetUserDefinedFunction",
            "glue:CreateTable",
            "glue:DeleteTable*",
            "glue:UpdateTable*"
          ],
          "Resource" : [
            "${aws_glue_catalog_database.aws_glue_catalog_database.arn}",
            "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
            "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/hive",
            "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${local.glue_db_name}/*",
            "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:userDefinedFunction/${local.glue_db_name}",
            "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:userDefinedFunction/${local.glue_db_name}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:Get*",
            "cloudwatch:List*",
            "cloudwatch:Put*"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:Create*",
            "logs:Describe*",
            "logs:Get*",
            "logs:Put*"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "ec2:Describe*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "sns:Publish",
          "Resource" : [
            "${aws_sns_topic.sns_alert.arn}"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : "lakeformation:*",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:BatchGetItem",
            "dynamodb:Describe*",
            "dynamodb:List*",
            "dynamodb:GetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:PartiQLSelect",
          ],
          "Resource" : [
            "${aws_dynamodb_table.status.arn}",
            "${aws_dynamodb_table.config.arn}",
            "${aws_dynamodb_table.logging.arn}"
          ]
        },
        {
          "Effect" : "Allow"
          "Action" : [
            "sts:AssumeRole"
          ],
          "Resource" : "*",
        }
      ]
    }
  )
}

resource "aws_s3_bucket_object" "mwaa_copy_requirements" {

  bucket = aws_s3_bucket.s3_bucket_airflow.bucket
  key    = "requirements.txt"
  source = "${path.module}/resources/mwaa/requirements.txt"

  tags = {
    md5 = "${filemd5("${path.module}/resources/mwaa/requirements.txt")}"
  }
}
