
variable "buckets_names" {
    type = list(string)
}

variable "proj_name" {
  description = "Project name"
}


///


resource "aws_s3_bucket" "buckets_GHA" {
    count = length(var.buckets_names)
    bucket = "${var.proj_name}-${var.buckets_names[count.index]}-${terraform.workspace}"


    #force destroy means that "terraform destroy" will be allowed to destroyt the buckets
    force_destroy = true
        tags = {
          project = "${var.proj_name}"
          environment = "${terraform.workspace}"
        }
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


output "buckets" {
  value = {
      for x in var.buckets_names : x => aws_s3_bucket.buckets_GHA[index(var.buckets_names, x)].bucket
    }
}
