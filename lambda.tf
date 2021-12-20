resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {

        Effect: "Allow",
        Action: [
          "lambda:InvokeFunction",
          "logs:*"
        ]
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Service: [
            "lambda.amazonaws.com",
            "apigateway.amazonaws.com"
            ]
        },
        Action: "sts:AssumeRole"
      }
    ]
  })
}

locals{
  lambda_zip_location = "outputs/index.zip"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "lambdaFunction"
  output_path = local.lambda_zip_location
}

resource "aws_lambda_function" "lambda_function" {
  filename      = local.lambda_zip_location
  function_name = "lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(local.lambda_zip_location)

  runtime = "nodejs12.x"

//  environment {
//    variables = {
//      foo = "bar"
//    }
//  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/GET/calculus/*"
}


output "base_url" {
  value = "${aws_api_gateway_deployment.example.invoke_url}/calculus/MiAqICgyMy8oMyozKSktIDIzICogKDIqMyk="
}
