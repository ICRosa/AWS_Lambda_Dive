variable "emails" {
  description = "receives the emails"
}

///

resource "aws_ses_domain_identity" "example" {
  domain = var.emails["domain"]
}

resource "aws_ses_email_identity" "example" {
  email = var.emails["destiny"]
}