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
    apigateway     = var.localstack_url
    iam            = var.localstack_url
    lambda         = var.localstack_url
    cloudwatch     = var.localstack_url
    cloudwatchlogs = var.localstack_url
  }
}

######################### API Gateway
resource "aws_api_gateway_rest_api" "this" {
  name = "my_rest_api"
}

# should instanciate a new api-gateway-endpoint module to create a new endpoint.
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

######################### Lambda function
data "archive_file" "lambda_echo_server" {
  type = "zip"

  source_dir  = "${path.module}/echo-server"
  output_path = "${path.module}/lambda_function_payload.zip"
}

resource "aws_iam_role" "lambda" {
  name               = "service_role_lambda"
  provider           = aws
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

# should instanciate a new lambda module to create a new lambda function.
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
