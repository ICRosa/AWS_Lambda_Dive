

resource "aws_glue_catalog_database" "gha-db" {
  name = "gha-db"
}

resource "aws_glue_crawler" "gha_crawler" {
  database_name = aws_glue_catalog_database.gha-db.name
  name          = "GHA_crawler"
  role          = var.params["role"] 

  table_prefix = "ghadata"

  schema_change_policy {
    delete_behavior = "LOG" 
    update_behavior = "LOG" 
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_NEW_FOLDERS_ONLY"
  } 

  s3_target {
    path = "s3://${var.params["bucket_target"]}"
  }

  tags = var.env_tags

}