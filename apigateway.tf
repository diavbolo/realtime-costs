
resource "aws_iam_role_policy" "readwrite_policy" {
  name = local.lambda_name
  role = aws_iam_role.readwriteRole.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Action" : [
          "dynamodb:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/*"
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
      }
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
  s3_bucket     = aws_s3_bucket.s3_bucket_airflow.bucket
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
  source_file = "${path.module}/resources/lambda/realtime-costs-lambda.py"
  output_path = "${path.module}/temp/${local.lambda_name}.zip"
}

resource "aws_s3_bucket_object" "copy_lambda" {

  bucket = aws_s3_bucket.s3_bucket_airflow.bucket
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
  path_part   = "register"

}

resource "aws_api_gateway_method" "readwriteMethod" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = aws_api_gateway_resource.readwriteResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "readwriteInt" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.readwriteResource.id
  http_method = aws_api_gateway_method.readwriteMethod.http_method

  # See https://stackoverflow.com/questions/46767947/aws-api-gateway-error-api-gateway-does-not-have-permission-to-assume-the-provid 
  credentials = aws_iam_role.readwriteRole.arn

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.readwriteLambda.invoke_arn

}

resource "aws_api_gateway_deployment" "apideploy" {
  depends_on = [aws_api_gateway_integration.readwriteInt]

  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = var.api_stage
}

resource "aws_lambda_permission" "readwritePermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.readwriteLambda.function_name
  principal     = "apigateway.amazonaws.com"

  # See https://stackoverflow.com/questions/54835528/aws-api-gateway-and-lambda-function-deployed-through-terraform-execution-fail/54868502#54868502
  source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/*/POST/${aws_api_gateway_resource.readwriteResource.path_part}"
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = aws_api_gateway_deployment.apideploy.stage_name
  domain_name = aws_api_gateway_domain_name.api_subdomain.domain_name
}
