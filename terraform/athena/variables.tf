
#Bucket to be used to store the querys
variable "dest_bucket" {
  
}

#Environment vars
variable "env_tags" {
  type = map(string)
  default = {}
}