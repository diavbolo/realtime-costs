
resource "aws_iam_role_policy" "readwrite_policy" {
  name = local.lambda_name
  role = aws_iam_role.readwriteRole.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Action" : [
          "dynamodb:BatchGetItem",
          "dynamodb:Describe*",
          "dynamodb:List*",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PartiQLSelect",
          "dynamodb:Put*"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "${aws_dynamodb_table.status.arn}",
          "${aws_dynamodb_table.config.arn}",
          "${aws_dynamodb_table.logging.arn}"
        ]
      },
      {
        "Sid" : "",
        "Resource" : "*",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow"
      },
      {
        "Sid" : "",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Effect" : "Allow",
        "Resource" : "${aws_lambda_function.readwriteLambda.arn}"
      },
    ]
  })
}

resource "aws_iam_role" "readwriteRole" {
  name               = local.dynamodb_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": 
          ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_lambda_function" "readwriteLambda" {
  function_name = local.lambda_name
  s3_bucket     = aws_s3_bucket.data.bucket
  s3_key        = "lambda/${data.archive_file.lambda_zip.output_base64sha256}.zip"
  role          = aws_iam_role.readwriteRole.arn
  handler       = "${local.lambda_name}.handler"
  runtime       = "python3.8"

  depends_on = [aws_s3_bucket_object.copy_lambda]

  environment {
    variables = {
      logging = aws_dynamodb_table.logging.name,
      status  = aws_dynamodb_table.status.name
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/resources/lambda/${local.lambda_name}.py"
  output_path = "${path.module}/temp/${local.lambda_name}.zip"
}

resource "aws_s3_bucket_object" "copy_lambda" {

  bucket = aws_s3_bucket.data.bucket
  key    = "lambda/${data.archive_file.lambda_zip.output_base64sha256}.zip"
  source = "${path.module}/temp/${local.lambda_name}.zip"

  tags = {
    sha = data.archive_file.lambda_zip.output_base64sha256
  }
}

resource "aws_api_gateway_rest_api" "apiLambda" {
  name = local.lambda_name

}

resource "aws_api_gateway_resource" "readwriteResource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = var.api_path

}

resource "aws_api_gateway_method" "readwriteMethod" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = aws_api_gateway_resource.readwriteResource.id
  http_method   = var.api_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "readwriteInt" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.readwriteResource.id
  http_method = aws_api_gateway_method.readwriteMethod.http_method

  # See https://stackoverflow.com/questions/46767947/aws-api-gateway-error-api-gateway-does-not-have-permission-to-assume-the-provid 
  credentials = aws_iam_role.readwriteRole.arn

  integration_http_method = var.api_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.readwriteLambda.invoke_arn

}

resource "aws_api_gateway_deployment" "apideploy" {
  depends_on = [aws_api_gateway_integration.readwriteInt]

  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = var.api_stage
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = aws_api_gateway_deployment.apideploy.stage_name
  domain_name = aws_api_gateway_domain_name.api_subdomain.domain_name
}
