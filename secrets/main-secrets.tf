variable "app_name" {}
variable "app_environment" {}

# this module creates credentials that are used for the RDS database, it can be logically
# extended to convey other credentials that need to be stored in AWS Secrets Manager
#

# create a random password

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

#
# workaround for issue where a secret isn't deleted immediately, we'll assign it a unique
# 6 digit number for the suffix
#

resource "random_integer" "suffix" {
  min = 1
  max = 999999
  keepers = {
    first = "${timestamp()}"
  }
}

locals {
  secret_name = "${lower(var.app_name)}-${var.app_environment}-rds-creds-${resource.random_integer.suffix.result}"
}

# Creating a AWS secret for passwords, passwordEntry

resource "aws_secretsmanager_secret" "passwordEntry" {
  name = local.secret_name
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-rds-credentials"
    Environment = var.app_environment
  }

}

# Create an AWS secret version for what we're saving

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.passwordEntry.id
  secret_string = <<EOF
   {
    "username": "sa",
    "password": "${random_password.password.result}"
   }
EOF
}

# Import the AWS secrets created previously using arn.

data "aws_secretsmanager_secret" "passwordEntry" {
  arn = aws_secretsmanager_secret.passwordEntry.arn
}

# Importing the AWS secret version created previously using arn.

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.passwordEntry.arn
}

# After importing the secret store it into Locals

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

output "username" {
  value = local.db_creds.username
}

output "password" {
  value = local.db_creds.password
}