
locals {
  env_tags = {terraform = true, env = "${terraform.workspace}"}
}


///


#Buckets
module "buckets" {
  source = "./buckets/"

  buckets_names = var.buckets_names
  proj_name     = var.proj_name
}


#IAMs
module "IAM" {
  source = "./IAM/"

  needs_an_role = {
    "gha_sheduler"            = "adm"
    "GHA_Activity_SFN"        = "adm"
    "GHA_to_S3_ingest_lambda" = "ingest_lambda"
    "json_to_parquet_lambda"  = "adm"
    "Athena_GHA_Query_Lambda" = "adm"
    "GHA_glue_crawler"        = "adm"
    }
}

#Lambda Layers
module "layers" {
  source = "./layers/"

  host_bucket = module.buckets.buckets["lamblayers"]

  list_of_layers = ["pandas", "fspec_s3fs", "requests"]

  depends_on = [
    module.buckets
  ]
}

#Lambdas
module "lambdas" {
  source = "./lambdas/"

  lambdas = {
    GHA_to_S3_ingest_lambda = {
      role = module.IAM.arns["GHA_to_S3_ingest_lambda"], 
      environment = "{target_bucket: ${module.buckets.buckets["raw"]}}",
      timeout = 80,
      memory_size = 800,
      layer = "pandas, requests"
      },
    
    json_to_parquet_lambda = {
      role = module.IAM.arns["json_to_parquet_lambda"],
      environment = "{target_bucket: ${module.buckets.buckets["processed"]}}",
      layer = "pandas, fspec_s3fs",
      timeout = 80,
      memory_size = 800
      },

    Athena_GHA_Query_Lambda = {
      role = module.IAM.arns["Athena_GHA_Query_Lambda"]
      environment = "{target_bucket: ${module.buckets.buckets["curated"]}}",
      timeout = 80
      }
  }

  layers = module.layers.layers_arns

  depends_on = [
    module.layers,
    module.IAM
  ]
}

#Dynamo
module "dynamo" {
  source = "./dynamo/"
}

#Step Functions
module "stepfunctions" {
  source = "./stepfunctions/"

  SFN = {
    GHA_Activity_SFN = {
      role_arn = module.IAM.arns["GHA_Activity_SFN"]
    }}

  lambdas = module.lambdas.arns

  depends_on = [
    module.IAM
  ]

}


#Glue
module "glue" {
  source = "./glue/"

  params = {
    role = module.IAM.arns["GHA_glue_crawler"]
    bucket_target = module.buckets.buckets["processed"]
  }
}


#Cloudwatch
module "cloudwatch" {
  source = "./cloudwatch/"

  schedule = {
    GHA_hourly = {
        schedule_expression = "cron(0 * * * ? *)"
        target_arn = module.stepfunctions.sfn_arns["GHA_Activity_SFN_${terraform.workspace}"]
        role_arn = module.IAM.arns["gha_sheduler"]
    }
  }

  depends_on = [
    module.stepfunctions,
    module.IAM
  ]
}

#SES
module "SES" {
  source = "./SES/"
}

#Athena
module "athena" {
  source = "./athena/"

  dest_bucket = module.buckets.buckets["curated"]
}