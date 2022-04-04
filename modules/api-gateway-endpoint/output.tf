output "stage_name" {
  value = aws_api_gateway_deployment.this.stage_name
}

output "aws_invoke_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}

output "path" {
  value = aws_api_gateway_resource.this.path
}

output "http_method" {
  value = aws_api_gateway_method.this.http_method
}
