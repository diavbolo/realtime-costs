
resource "aws_glue_crawler" "ec2_costs" {
  name          = local.crawler_name
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  role          = aws_iam_role.ec2_costs_role.name
  classifiers   = ["${aws_glue_classifier.csv.name}", "${aws_glue_classifier.json.name}"]
  schedule      = "cron(0 */8 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.data.bucket}/"
  }

  jdbc_target {
    connection_name = aws_glue_connection.mysql.name
    path            = "${var.mysql_db_name}/%"
  }

}

resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = local.glue_db_name
}

resource "aws_glue_classifier" "json" {
  name = "json"

  json_classifier {
    json_path = "."
  }
}

resource "aws_iam_role" "ec2_costs_role" {
  name = local.glue_name
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "glue.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_glue_classifier" "csv" {
  name = "csv"

  csv_classifier {
    allow_single_column    = false
    contains_header        = "PRESENT"
    delimiter              = ","
    disable_value_trimming = false
    quote_symbol           = "\""
  }
}

resource "aws_iam_policy_attachment" "ec2_costs_policy" {
  name       = "AWSGlueServiceRole"
  roles      = ["${aws_iam_role.ec2_costs_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy_document" "ec2_costs_policy1" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}",
      "${aws_s3_bucket.data.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "ec2_costs_policy1" {
  name = local.glue_name

  path   = "/"
  policy = data.aws_iam_policy_document.ec2_costs_policy1.json
}

resource "aws_iam_role_policy_attachment" "ec2_costs_policy1" {
  role       = aws_iam_role.ec2_costs_role.name
  policy_arn = aws_iam_policy.ec2_costs_policy1.arn
}
