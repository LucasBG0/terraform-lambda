terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
  region = var.myregion

  # access_key = "fake"
  # secret_key = "fake"
  # skip_credentials_validation = true
  # skip_metadata_api_check     = true
  # skip_requesting_account_id  = true

  # endpoints {
  #   apigatewayv2   = "http://localhost:4566"
  #   apigateway     = "http://localhost:4566"
  #   iam            = "http://localhost:4566"
  #   lambda         = "http://localhost:4566"
  #   cloudwatch     = "http://localhost:4566"
  #   cloudwatchlogs = "http://localhost:4566"
  #   cloudfront     = "http://localhost:4566"
  # }
}


# API Gateway
resource "aws_api_gateway_rest_api" "echo_server" {
  name = "${var.stage_name}_rest_api"
}

resource "aws_api_gateway_resource" "echo_server" {
  path_part   = "echo_server"
  parent_id   = aws_api_gateway_rest_api.echo_server.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.echo_server.id
}

resource "aws_api_gateway_method" "echo_server" {
  rest_api_id   = aws_api_gateway_rest_api.echo_server.id
  resource_id   = aws_api_gateway_resource.echo_server.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "echo_server" {
  rest_api_id             = aws_api_gateway_rest_api.echo_server.id
  resource_id             = aws_api_gateway_resource.echo_server.id
  http_method             = aws_api_gateway_method.echo_server.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.echo_server.invoke_arn
}

resource "aws_api_gateway_deployment" "echo_server" {
  rest_api_id = aws_api_gateway_rest_api.echo_server.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.echo_server.id,
      aws_api_gateway_method.echo_server.id,
      aws_api_gateway_integration.echo_server.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "echo_server" {
  deployment_id = aws_api_gateway_deployment.echo_server.id
  rest_api_id   = aws_api_gateway_rest_api.echo_server.id
  stage_name    = var.stage_name
}

# Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.echo_server.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.echo_server.execution_arn}/*/${aws_api_gateway_method.echo_server.http_method}${aws_api_gateway_resource.echo_server.path}"
}

resource "aws_iam_role" "lambda" {
  name = "service_role_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_echo_server" {
  type = "zip"

  source_dir  = "${path.module}/echo-server"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_lambda_function" "echo_server" {
  filename         = "lambda_function_payload.zip"
  function_name    = "lambda_echo_server"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_echo_server.output_base64sha256

  runtime = "nodejs14.x"
}
