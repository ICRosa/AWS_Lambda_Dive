<div align="center">
  
  ![GitHub release (latest by date)](https://img.shields.io/github/v/release/ICRosa/AWS_Lambda_Dive?color=purple)
  ![GitHub Last Commit](https://img.shields.io/github/last-commit/ICRosa/AWS_Lambda_Dive?color=purple)
  
</div>

## AWS_Lambda_Dive :swimming_man:

This is a project that uses terraform to deploy a application that runs 

- [Utilities and Advantages](#utilities-and-advantages)
- [Terraform apply](#terraform-apply)
- [Terraform level, noted issues](#terraform-level-noted-issues)
- [Localstack deploy level, noted issues](#localstack-deploy-level-noted-issues)
- [Localstack](#what-is-localstack)


---

## Utilities and Advantages 🛠️ 

- It's a modifiable ETL workflow built to GitHub activity data  

- The whole process is conected to a scheduled state machine

- Free testing of most of the deploying process with [localstack](#what-is-localstack) community

- Easy and fast to deploy use and destroy with Terraform

- Mostly the code allows you to change and scale the code drastically only by edditing the *main.tf* and the *terraform.tfvars* 

---

Pipeline Diagram

<img src="./Diagrams/GHA Analisis Pipeline.jpg">


## Terraform config :purple_circle:

### There are a fell steps to run this environment:

### 1. Clone this repository. [Click here](https://github.com/ICRosa/AWS_Lambda_Dive/archive/refs/heads/main.zip)

### 2. Install terraform

  In windows using [Chocolatey](https://chocolatey.org/install)
  ```cmd
  choco install terraform
  ```

  Or in linux using either apt-get or yum
  ```cmd
  sudo apt-get install terraform
  ```
  ```cmd
  sudo yum install terraform
  ```

### 3. Install and run Docker (If you wanna try localstack)

  - [Windows](https://docs.docker.com/desktop/install/windows-install/)

  - [linux](https://docs.docker.com/engine/install/ubuntu/)

  ```cmd
  docker run  -p 4566:4566 -p 4571:4571 -p 4510-4559:4510-4559  -v "/var/run/docker.sock:/var/run/docker.sock" --name localstack_main localstack/localstack
  ```


### 4. Configure Terraform

  4.1. Open a terminal in ./terraform dir of this repository

  4.2. Init terraform modules and provider

```cmd
terraform init
```
  4.3. (Optional) Set the workspace to "dev"

```cmd
terraform workspace new dev
```
Changing workspace to "dev" may set the endpoints to localstack

  4.4. Run *terraform apply* using your credentials 

```cmd
terraform plan

var.acces_key
  your AWS acces_key

  Enter a value: <your_access_key>

var.secret_key
  your AWS secret_key

  Enter a value: <your_secret_key>
```
### 5. Set tfvars
  If  you don't want to put your credentials every time you run *terraform apply* you can put then in _terraform.tfvars_ as indicated in the commented part of this file.



Run Terraform on workspace "dev" to auto change the endpoints to [localstack](#what-is-localstack) any other workspace name points to default aws us-east-1

---

## Terraform level, noted issues :notebook:

SES varification for non enterprise account seems to fail due to the need of an email verification. (Just verify the email before running the state machine and it will work)

---

## Localstack deploy level, noted issues :blue_book:

I used [localstack](#what-is-localstack) pro to test lambda layers properly, you can also deploy your lambda dependencies with the function to keep using only the community version

---

## What is Localstack :cloud:

Localstack is a locally emulated AWS cloud where you can freely use your computer processing to test your aplications, to get further informations you can access [their git](https://github.com/localstack/localstack) or [their official page](https://localstack.cloud/).

---


:receipt: Planning to do:

- Improve ETL process with spark
- Give specific IAM roles to resources