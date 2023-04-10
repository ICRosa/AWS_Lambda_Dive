

variable "schedule" {
  type = map(map(string))
}

variable "env_tags" {
  type = map(string)
  default = {}
}


///


resource "aws_cloudwatch_event_rule" "rules" {

  for_each = var.schedule

  name = "${each.key}_${terraform.workspace}"
  role_arn = try(each.value["role_arn"], "sheduler needs a target role arn")
  schedule_expression = try(each.value["schedule_expression"], "rate(2 days)")
}

resource "aws_cloudwatch_event_target" "match" {

  for_each = var.schedule

  rule      = aws_cloudwatch_event_rule.rules[each.key].name
  target_id = "${each.key}"
  arn       = try(each.value["target_arn"], "sheduler needs a target arn")
  role_arn = try(each.value["role_arn"], "sheduler needs a target role arn")

  depends_on = [
    aws_cloudwatch_event_rule.rules
  ]
}