{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
       "s3:*"
      ],
      "Resource": [
        "${artifact_bucket}",
        "${artifact_bucket}/*",
        "${destination_bucket}",
        "${destination_bucket}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Resource": [
        "${codebuild_project_test}",
        "${codebuild_project_build}"
      ],
      "Action": [
        "codebuild:*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Action": [
        "kms:DescribeKey",
        "kms:GenerateDataKey*",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:Decrypt"
      ],
      "Resource": [
      "${aws_kms_key}"
      ],
      "Effect": "Allow"
    }
  ]
}