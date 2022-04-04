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

  access_key                  = "fake"
  secret_key                  = "fake"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    iam            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
  }
}


######################### API Gateway
resource "aws_api_gateway_rest_api" "this" {
  name = "prod_rest_api"
}

module "api_endpoint_echo_server" {
  source                 = "./modules/api-gateway-endpoint"
  resource_endpoint_name = "echo_server"
  http_method            = "POST"
  lambda_invoke_arn      = module.lambda.lambda_invoke_arn
  rest_api = {
    parent_id  = aws_api_gateway_rest_api.this.root_resource_id
    id         = aws_api_gateway_rest_api.this.id
    stage_name = var.environment
  }
}

module "api_endpoint_echo_server2" {
  source                 = "./modules/api-gateway-endpoint"
  resource_endpoint_name = "echo_server2"
  http_method            = "POST"
  lambda_invoke_arn      = module.lambda.lambda_invoke_arn
  rest_api = {
    parent_id  = aws_api_gateway_rest_api.this.root_resource_id
    id         = aws_api_gateway_rest_api.this.id
    stage_name = var.environment
  }
}

######################### Lambda function
data "archive_file" "lambda_echo_server" {
  type = "zip"

  source_dir  = "${path.module}/echo-server"
  output_path = "${path.module}/lambda_function_payload.zip"
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

module "lambda" {
  source = "./modules/lambda"

  function_name    = "lambda_echo_server"
  filename         = data.archive_file.lambda_echo_server.output_path
  source_code_hash = data.archive_file.lambda_echo_server.output_base64sha256
  source_arn       = "${aws_api_gateway_rest_api.this.execution_arn}/*/${module.api_endpoint_echo_server.http_method}${module.api_endpoint_echo_server.path}"
  iam_role = {
    id  = aws_iam_role.lambda.id
    arn = aws_iam_role.lambda.arn
  }
}

module "lambda2" {
  source = "./modules/lambda"

  function_name    = "lambda_echo_server2"
  filename         = data.archive_file.lambda_echo_server.output_path
  source_code_hash = data.archive_file.lambda_echo_server.output_base64sha256
  source_arn       = "${aws_api_gateway_rest_api.this.execution_arn}/*/${module.api_endpoint_echo_server2.http_method}${module.api_endpoint_echo_server2.path}"
  iam_role = {
    id  = aws_iam_role.lambda.id
    arn = aws_iam_role.lambda.arn
  }
}
