output "lambda_arn" {
    value = aws_lambda_function.terraform_lambda_func.arn
  
}

output "last_modified" {
  value = aws_lambda_function.terraform_lambda_func.last_modified
}