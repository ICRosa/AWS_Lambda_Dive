

data "archive_file" "python_lambda_package" {  
  for_each = var.lambdas
  type = "zip"  
  source_file = "${path.module}/${each.key}/${each.key}.py" 
  output_path = "${path.module}/${each.key}/${each.key}.zip"
}


resource "aws_lambda_function" "lambdas" {

  for_each = var.lambdas

  filename = "${path.module}/${each.key}/${each.key}.zip"
  function_name                   = "${each.key}_${terraform.workspace}"
  handler                         = "${each.key}.lambda_handler"
  timeout                         = try(each.value["timeout"], 15)
  reserved_concurrent_executions  = try(each.value["reserved_concurrent_executions"], -1)
  memory_size                     = try(each.value["memory_size"], 128)
  role                            = try(each.value["role"],"arn:aws:iam::000000000000:role/fake-role-role")
  runtime                         = try(each.value["runtime"], "python3.9")
  source_code_hash                = data.archive_file.python_lambda_package[each.key].output_base64sha256
  layers                          = try([for x in split(", ", each.value["layer"]) : var.layers[x]], null)

  environment {
    variables = try(yamldecode(each.value["environment"]), null)
  }

  tags = merge({env = "${terraform.workspace}", "Terraform" = true}, try(yamldecode(each.value["tags"]), null))
}
