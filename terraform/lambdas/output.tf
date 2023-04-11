#Output the Lambdas arns by the input name
output "arns" {
    value = {
        for x, y in var.lambdas : x => "${aws_lambda_function.lambdas[x].arn}"
        }
}