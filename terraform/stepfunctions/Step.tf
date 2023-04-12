# Edit sfn json tamplete with inputed variables
data "template_file" "state_machine_definition" {

  for_each = var.SFN

  #SFN definition in ./stepfunctions/definitions
  template =  file("${path.module}/definitions/${each.key}.json")

  # Receive the lambdas arns to be in the SFN definition
  vars = merge(var.lambdas, var.emails)
}

# Create a SFN from the definition
resource "aws_sfn_state_machine" "sfn_state_machine" {
    for_each = var.SFN

    name     = "${each.key}_${terraform.workspace}"
    role_arn = each.value["role_arn"]

    definition = data.template_file.state_machine_definition["${each.key}"].rendered

    tags = var.env_tags
}