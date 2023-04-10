
data "template_file" "state_machine_definition" {

  for_each = var.SFN

  template =  file("${path.module}/definitions/${each.key}.json")
  vars = var.lambdas
}


resource "aws_sfn_state_machine" "sfn_state_machine" {
    for_each = var.SFN

    name     = "${each.key}_${terraform.workspace}"
    role_arn = each.value["role_arn"]

    definition = data.template_file.state_machine_definition["${each.key}"].rendered
}