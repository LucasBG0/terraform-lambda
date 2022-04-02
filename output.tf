output "api_gateway_url" {
  value = aws_api_gateway_stage.echo_server.invoke_url
}

output "api_arn" {
  value = aws_api_gateway_rest_api.echo_server.arn
}

output "api_arn2" {
  value = aws_api_gateway_rest_api.echo_server.execution_arn
}


# output "api_gateway_url_local" {
#   value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.example.id}/${aws_api_gateway_stage.example.stage_name}/_user_request_/path1"
# }
