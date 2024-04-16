# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Hashicorp-Learn = "aws-iam-policy"
    }
  }
}

data "aws_iam_policy_document" "document" {
  statement {
    actions   = [   "dynamodb:DeleteItem",
                    "dynamodb:GetItem",
                    "dynamodb:PutItem",
                    "dynamodb:Query",
                    "dynamodb:Scan",
                    "dynamodb:UpdateItem"
                ]
    resources = ["*"]
    effect = "Allow"
  }
  statement {
    actions   = [   "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
    resources = ["*"]
    effect = "Allow"
  }
}



resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-apigateway-policy"
  description = "Lambda policy"

  policy = data.aws_iam_policy_document.document.json
 
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-apigateway-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/LambdaFunctionOverHttps.py"
  # source_dir  = "${path.module}/python/"
  # output_path = "${path.module}/python/hello-python.zip"
  output_path = "${path.module}/function.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename                       = "${path.module}/function.zip"
  function_name                  = "LambdaFunctionOverHttps"
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "LambdaFunctionOverHttps.handler"
  runtime                        = "python3.9"
  depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]

  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
}

module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name                        = var.table_name
  hash_key                    = "id"
  range_key                   = "number"
  table_class                 = "STANDARD"
  deletion_protection_enabled = true
  autoscaling_enabled = true

  attributes = [  
    {
      name = "id"
      type = "S"
    },
    {
      name = "number"
      type = "N"
    },
    {
      name = "location"
      type = "S"
    }
  ]

  global_secondary_indexes = [{
    name               = "IdNumberIndex"
    hash_key           = "number"
    range_key          = "location"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["id"]
  }]
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = "DynamoDBOperations"
}

resource "aws_api_gateway_resource" "rest_resource" {
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "DynamoDBManager"
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_method" "rest_method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.rest_resource.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_method.http_method}${aws_api_gateway_resource.rest_resource.path}"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_resource.id
  http_method             = aws_api_gateway_method.rest_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.terraform_lambda_func.invoke_arn

  depends_on                     = [aws_lambda_function.terraform_lambda_func]
}