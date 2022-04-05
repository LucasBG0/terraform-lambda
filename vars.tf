variable "myregion" {
  default = "us-east-1"
  type    = string
}

variable "environment" {
  default = "prod"
}

variable "localstack_url" {
  default = "http://localhost:4566"
}
