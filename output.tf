output "api_gateway_url_aws" {
  value = "${module.api_endpoint_echo_server.aws_invoke_url}${module.api_endpoint_echo_server.path}"
}

output "api_gateway_url_localstack" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.this.id}/${module.api_endpoint_echo_server.stage_name}/_user_request_${module.api_endpoint_echo_server.path}"
}
