#Vars from the root
variable "needs_an_role" {
    description = "map of resources and policies they need"
}


#Crete policy documents
data "aws_iam_policy_document" "policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com", 
        "states.amazonaws.com", 
        "lambda.amazonaws.com",
        "events.amazonaws.com"
        ]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

  }
}




#Create Roles
resource "aws_iam_role" "general" {
  
    for_each = var.needs_an_role
  
    name = "${each.key}_${terraform.workspace}"

    assume_role_policy = data.aws_iam_policy_document.policy.json


    inline_policy {
        name   = "${each.value}"
        policy = file("${path.module}/policies/${each.value}.json")
    }

}

#Output the Roles arns by the input name
output "arns" {
    value = {
        for x, y in var.needs_an_role : x => "${aws_iam_role.general[x].arn}"
        }
}