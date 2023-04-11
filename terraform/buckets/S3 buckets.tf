
#Environment vars
variable "env_tags" {
  type = map(string)
  default = {}
}

variable "buckets_names" {
    type = list(string)
    description = "Buckets to be created"
}

variable "proj_name" {
  description = "Project name"
}


///

#Create Buckets
resource "aws_s3_bucket" "buckets_GHA" {
    count = length(var.buckets_names)
    bucket = "${var.proj_name}-${var.buckets_names[count.index]}-${terraform.workspace}"


    #force destroy means that "terraform destroy" will be allowed to destroy the buckets
    force_destroy = true
        tags = var.env_tags
  }

  resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = length(var.buckets_names)
  bucket = "${var.proj_name}-${var.buckets_names[count.index]}-${terraform.workspace}"
  acl    = "private"

}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count  = length(var.buckets_names)
  bucket = "${var.proj_name}-${var.buckets_names[count.index]}-${terraform.workspace}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


///

#Outputs a dict with the input names as key and the actual names as value
output "buckets" {
  value = {
      for x in var.buckets_names : x => aws_s3_bucket.buckets_GHA[index(var.buckets_names, x)].bucket
    }
}
