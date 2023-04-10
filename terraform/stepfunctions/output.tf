output "sfn_arns" {
    value = {
        for x, y in aws_sfn_state_machine.sfn_state_machine : y.name => "${y.arn}"
        }
}