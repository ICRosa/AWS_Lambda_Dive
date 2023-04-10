

data "archive_file" "zip_layer" { 

  count = length(var.list_of_layers)
  
  type = "zip"  
  source_dir = "${path.module}/${var.list_of_layers[count.index]}/" 
  excludes = fileset("${path.module}/${var.list_of_layers[count.index]}", "*.*")
  output_path = "${path.module}/${var.list_of_layers[count.index]}/${var.list_of_layers[count.index]}.zip"
}


resource "aws_s3_object" "upload_layer" {

  count = length(var.list_of_layers)

  key                    = "${var.list_of_layers[count.index]}.zip"
  bucket                 = var.host_bucket
  source                 = "${path.module}/${var.list_of_layers[count.index]}/${var.list_of_layers[count.index]}.zip"

  depends_on = [
    data.archive_file.zip_layer
  ]
}

resource "aws_lambda_layer_version" "lambda_layer" {

  count = length(var.list_of_layers)

  s3_bucket     = var.host_bucket
  s3_key        = "${var.list_of_layers[count.index]}.zip"

  #filename = "${path.module}/${var.list_of_layers[count.index]}/${var.list_of_layers[count.index]}.zip"
  layer_name    = "${var.list_of_layers[count.index]}"

  compatible_runtimes = ["python3.9"]
  depends_on = [
    aws_s3_object.upload_layer
  ]
}

output "layers_arns" {
  value = {
      for x in var.list_of_layers : x => aws_lambda_layer_version.lambda_layer[index(var.list_of_layers, x)].arn
    }
}