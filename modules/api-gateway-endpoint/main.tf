resource "aws_api_gateway_resource" "this" {
  path_part   = var.resource_endpoint_name
  parent_id   = var.rest_api.parent_id
  rest_api_id = var.rest_api.id
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = var.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.rest_api.id
  stage_name  = var.rest_api.stage_name

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this.id,
      aws_api_gateway_method.this.id,
      aws_api_gateway_integration.this.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
