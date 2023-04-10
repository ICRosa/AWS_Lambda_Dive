## AWS_Lambda_Dive

- [Utilities and Advantages](#utilities-and-advantages)
- [Terraform apply](#terraform-apply)
- [Terraform level, noted issues](#terraform-level-noted-issues)
- [Localstack deploy level, noted issues](#localstack-deploy-level-noted-issues)
- [Localstack](#what-is-localstack)


---

## Utilities and Advantages

- It's a modifiable ETL workflow builded to GitHub activity data  

- The whole process is conected to a scheduled state machine

- Free testing most of the deployng process with [localstack](#what-is-localstack)

- Easy and fast to deploy use and destroy with Terraform

- Mostly the code allow you to change and scale drastically the code only by edditing the *main.tf* and the *terraform.tfvars* 

---

Pipeline Diagram
<img src="./Diagrams/GHA Analisis Pipeline.jpg">

</div>

## Terraform apply

Don't forget to run "*terraform init*" to set the provider and modules

Run Terraform on workspace "dev" to auto change the endpoints to [localstack](#what-is-localstack) 

---

## Terraform level, noted issues

SES varification for non enterprise account seems to fail due to the need of an email verification.

---

## Localstack deploy level, noted issues

Glue tends to have a issue when creating a database, you can work around this by creating a database with awscli and runining terraform with the *"aws_glue_catalog_database"* commented when testing.

Also lambda layers system doesn't work well in [localstack](#what-is-localstack) community version but you can also upload the dependencies with the function

## What is Localstack

Localstack is a localy emulated AWS cloud where you can freely use your computer processing to test your aplications to get further informations you can access [their git](https://github.com/localstack/localstack) or [their official page](https://localstack.cloud/).

---

</div>

---
To do:

- Improve ETL process with spark
- Give specific IAM roles to resources