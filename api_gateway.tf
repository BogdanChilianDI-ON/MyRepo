resource "aws_api_gateway_rest_api" "example" {
  name        = "Example"
  description = "Terraform Serverless Application Example"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "calculus"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.proxy.id
  request_parameters = {"method.request.querystring.input" = true}
 // request_validator_id= aws_api_gateway_request_validator.example1.id

  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_request_validator" "example1" {
  name                        = "example1"
  rest_api_id                 = aws_api_gateway_rest_api.example.id
  validate_request_body       = false
  validate_request_parameters = true
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
  request_templates = {
    "application/json" = <<EOF
{
   "input":  "$input.params('input')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_rest_api.example,
    aws_api_gateway_resource.proxy,
    aws_api_gateway_method.proxy,
    aws_api_gateway_method_response.response_200,
    aws_api_gateway_integration.lambda
  ]
}

////next path: /input
resource "aws_api_gateway_resource" "proxy2" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_resource.proxy.id
  path_part   = "{input}"
}

resource "aws_api_gateway_method" "proxy2" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.proxy2.id

  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda2" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_method.proxy2.resource_id
  http_method = aws_api_gateway_method.proxy2.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
{
   "input":  "$input.params('input')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "response2_200" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.proxy2.id
  http_method = aws_api_gateway_method.proxy2.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse2" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.proxy2.id
  http_method = aws_api_gateway_method.proxy2.http_method
  status_code = aws_api_gateway_method_response.response2_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_rest_api.example,
    aws_api_gateway_resource.proxy2,
    aws_api_gateway_method.proxy,
    aws_api_gateway_method_response.response2_200,
    aws_api_gateway_integration.lambda2
  ]
}


resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda2
  ]

  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "api"
}



