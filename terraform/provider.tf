terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "${var.acces_key}"
  secret_key = "${var.secret_key}"
  s3_use_path_style           = ("${terraform.workspace}" == "dev") ? true : null
  skip_credentials_validation = ("${terraform.workspace}" == "dev") ? true : null
  skip_metadata_api_check     = ("${terraform.workspace}" == "dev") ? true : null
  skip_requesting_account_id  = ("${terraform.workspace}" == "dev") ? true : null

  endpoints {         
    athena         = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    apigateway     = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    cloudformation = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    cloudwatch     = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    dynamodb       = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    ec2            = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    es             = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    elasticache    = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    eventbridge    = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    firehose       = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    glue           = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    gluedatabrew   = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    iam            = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    kinesis        = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    lambda         = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    rds            = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    redshift       = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    route53        = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    s3             = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    secretsmanager = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    ses            = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    sns            = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    sqs            = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    ssm            = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    stepfunctions  = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
    sts            = ("${terraform.workspace}" == "dev") ? "http://localhost:4566" : null
  }
}