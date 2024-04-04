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

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}