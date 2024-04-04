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



resource "aws_iam_policy" "policy" {
  name        = "lambda-apigateway-policy"
  description = "Lambda policy"

  policy = data.aws_iam_policy_document.document.json

  
}