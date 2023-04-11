
#Environment vars
variable "env_tags" {
  type = map(string)
  default = {}
}


variable "params" {
    default = {
        role = "Clrawler need a role"
        bucket_target = {}
    }
}
