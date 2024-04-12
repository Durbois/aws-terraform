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

resource "aws_dynamodb_table" "table" {
  name = var.table_name
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  } 
}