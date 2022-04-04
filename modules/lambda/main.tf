resource "aws_lambda_function" "echo_server" {
  filename         = var.filename
  function_name    = var.function_name
  role             = var.iam_role.arn
  handler          = "index.handler"
  source_code_hash = var.source_code_hash

  runtime = "nodejs14.x"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.echo_server.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.source_arn
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = var.iam_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
