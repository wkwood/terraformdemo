variable "rds_instance_class" {
  default = "db.t3.xarge"
  type    = string
}

variable "allocated_storage" {
  default = 50
  type    = number
}

variable "timezone" {
  default = "Pacific Standard Time"
  type    = string
}

variable "databasename" {
  type = string
}

variable "rds_sg_id" {}
variable "rds_subnet_id" {}
variable "vpc_id" {}
variable "rds_backup_subnet_id" {}
variable "vpc_cidr" {}
variable "app_environment" {}
variable "app_name" {}

variable "admin_username" {
  type    = string
  default = "sa"
}

variable "admin_password" {
  type    = string
  default = "changeme1"
}

resource "aws_db_subnet_group" "public" {
  name       = "public_subnets"
  subnet_ids = [var.rds_subnet_id, var.rds_backup_subnet_id]
  tags = {
    name = "public DB subnets"
  }
}

locals {
  max_storage = var.allocated_storage * 10
}

# to take the guess work in determining what instance classes are supported for a database engine and version, use the following aws cli command
#
#
# aws rds describe-orderable-db-instance-options --engine engine --engine-version version \
#    --query "*[].{DBInstanceClass:DBInstanceClass,StorageType:StorageType}|[?StorageType=='gp2']|[].{DBInstanceClass:DBInstanceClass}" \
#    --output text \
#    --region region
#


resource "aws_db_instance" "rds" {

  identifier                 = var.databasename
  engine                     = "sqlserver-web"   # sqlserver-ex,-ee,-se
  engine_version             = "15.00.4198.2.v1" # SQLServer 2019 CU15
  instance_class             = var.rds_instance_class
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = local.max_storage
  storage_type               = "gp2"
  license_model              = "license-included"
  auto_minor_version_upgrade = true
  vpc_security_group_ids     = [var.rds_sg_id]
  maintenance_window         = "sun:20:00-sun:22:00"
  backup_window              = "23:00-23:59"
  backup_retention_period    = 7

  username = var.admin_username
  password = var.admin_password

  skip_final_snapshot  = true
  publicly_accessible  = true
  apply_immediately    = true
  timezone             = var.timezone
  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.public.id

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-sql-server"
    Environment = var.app_environment
  }

}