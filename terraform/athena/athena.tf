
#Creates a KMS key to be used by the workgroup
resource "aws_kms_key" "a" {
  description             = "KMS key 1"
  deletion_window_in_days = 7
}


#Creates an Athena workgroup 
resource "aws_athena_workgroup" "gha_wg" {
  name = "gha"

  configuration {

    result_configuration {

      #Configure a S3 to store query results
      output_location = "s3://${var.dest_bucket}/"


      #uses the KMS key
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.a.arn
        }
    }
  }

  # allows to auto destroy even if not empty
  force_destroy  = true
  tags = var.env_tags
}
