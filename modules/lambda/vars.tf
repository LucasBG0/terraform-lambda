variable "function_name" {
  type = string
}

variable "filename" {
  type = string
}

variable "source_code_hash" {
  type = string
}

variable "source_arn" {
  type = string
}

variable "iam_role" {
  type = map(string)
}
