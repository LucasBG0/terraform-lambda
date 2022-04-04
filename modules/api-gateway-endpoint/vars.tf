variable "rest_api" {
  type = map(string)
}

variable "resource_endpoint_name" {
  type = string
}

variable "http_method" {
  type = string
}

variable "lambda_invoke_arn" {
  type = string
}
