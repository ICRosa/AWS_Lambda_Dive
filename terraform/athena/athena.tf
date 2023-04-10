
resource "aws_kms_key" "a" {
  description             = "KMS key 1"
  deletion_window_in_days = 7
}

resource "aws_athena_workgroup" "gha_wg" {
  name = "gha"

  configuration {

    # enforce_workgroup_configuration = true
    result_configuration {
      output_location = "s3://${var.dest_bucket}/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.a.arn
        }
    }
  }

  force_destroy  = true

}

///

##The below are good ideas but dont work as expected yet

# resource "null_resource" "athena_prepared_statement" {

#   provisioner "local-exec" {
#     command = "aws athena start-query-execution --query-string 'PREPARE hourly_query FROM SELECT count(\"created_at\") FROM \"gha-db\".\"ghadata.ghactivity\" WHERE created_at BETWEEN ? AND ?' --work-group gha"
#   }



#   depends_on = [
#     aws_athena_workgroup.gha_wg
#   ]
# }


# resource "aws_athena_named_query" "gha_hourly" {
#   name      = "gha_hourly"
#   workgroup = "gha"
#   database  = "gha-db"
#   query     = "PREPARE hourly_query FROM SELECT count(\"created_at\") FROM \"gha-db\".\"ghadata.ghactivity\" WHERE created_at BETWEEN ? AND ?"
# }