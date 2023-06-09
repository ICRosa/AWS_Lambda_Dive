
#Environment vars
variable "env_tags" {
  type = map(string)
  default = {}
}

///

resource "aws_dynamodb_table" "jobs" {
  name           = "jobs"
  hash_key       = "job_id"
  billing_mode   = "PAY_PER_REQUEST"
  
  attribute {
    name = "job_id"
    type = "N"
  }

  tags = var.env_tags
}