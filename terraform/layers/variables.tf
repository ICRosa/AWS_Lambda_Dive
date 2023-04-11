# Where the layer will be stored
variable "host_bucket" {
    description = "bucket name"
}

#Each name corresponds to a directory containing the layer dependencies (also will be the name of the layer)
variable "list_of_layers" {
    default = ["pandas", "fspec_s3fs", "requests"]
}