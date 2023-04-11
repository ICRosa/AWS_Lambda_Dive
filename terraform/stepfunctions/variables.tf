
#Environment vars
variable "env_tags" {
  type = map(string)
  default = {}
}

# SFN definition maps
variable "SFN"{
    type = map(map(string))
    description = "map of sfn names and attributes they need"
}


#lambdas arns by input names
variable "lambdas" {
}

#emails
variable "emails" { 
}