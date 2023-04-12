
#Environment vars
variable "env_tags" {
  type = map(string)
  default = {}
}

#Lambda configuration map
variable "lambdas" {
    type = map(map(any)) 
}


#Hols the output of the module layers
variable "layers" {
    description = "Layers arns"
}

