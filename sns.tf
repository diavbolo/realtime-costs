
resource "aws_iam_role" "sns_alert" {
  name = local.sns_name

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": [ "es.amazonaws.com" ]
        },
        "Effect": "Allow"
      }
    ]
}
EOF
}

data "aws_iam_policy_document" "sns_alert" {
  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = [
      "${aws_sns_topic.sns_alert.arn}"
    ]
  }

}

resource "aws_iam_policy" "sns_alert" {
  name = local.sns_name

  path   = "/"
  policy = data.aws_iam_policy_document.sns_alert.json
}

resource "aws_iam_role_policy_attachment" "attach_sns_alert_policy_to_sns_alert_role" {
  role       = aws_iam_role.sns_alert.name
  policy_arn = aws_iam_policy.sns_alert.arn
}

resource "aws_sns_topic" "sns_alert" {
  name = local.sns_name
}

resource "aws_sns_topic_subscription" "topic_email_subscription" {
  topic_arn = aws_sns_topic.sns_alert.arn
  protocol  = "email"
  endpoint  = var.sns_notification
}

data "aws_iam_policy_document" "sns_alert_policy" {
  statement {
    actions = [
      "SNS:Publish",
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com", "cloudwatch.amazonaws.com"]
    }
    resources = [aws_sns_topic.sns_alert.arn]
    sid       = ""
  }
}

resource "aws_sns_topic_policy" "sns_alert_policy" {
  arn    = aws_sns_topic.sns_alert.arn
  policy = data.aws_iam_policy_document.sns_alert_policy.json
}
