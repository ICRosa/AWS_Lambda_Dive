#Output the Roles arns
output "arns" {
    value = {
        for x, y in var.lambdas : x => "${aws_lambda_function.lambdas[x].arn}"
        }
}