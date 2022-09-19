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

# Creating a AWS secret for passwords, passwordDB

resource "aws_secretsmanager_secret" "passwordDB" {
  name = "${lower(var.app_name)}-${var.app_environment}-rds-credentials"
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-rds-credentials"
    Environment = var.app_environment
  }

}

# Create an AWS secret version for what we're saving

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.passwordDB.id
  secret_string = <<EOF
   {
    "username": "sa",
    "password": "${random_password.password.result}"
   }
EOF
}

# Import the AWS secrets created previously using arn.

data "aws_secretsmanager_secret" "passwordDB" {
  arn = aws_secretsmanager_secret.passwordDB.arn
}

# Importing the AWS secret version created previously using arn.

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.passwordDB.arn
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