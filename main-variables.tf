variable "app_name" {
  type        = string
  description = "The name of the application"
  default     = "testapp"
  validation {
    error_message = "Value must not have any spaces or tabs in it."
    condition     = !can(regex("\\s+", var.app_name))
  }
}

variable "app_environment" {
  type        = string
  description = "Application environment"
  default     = "dev"
  validation {
    error_message = "Value must be dev|test|stage|prod"
    condition     = can(regex("[dev|test|stage|prod]", var.app_environment))
  }
}

# AWS Region where the primary RDS instance and windows server are hosted.
variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
  validation {
    error_message = "Value must lower case and in the form of xx-xxxx-[1-3]"
    condition     = can(regex("[a-z]{2}-[gov-]?[a-z]{4}-[1-3]", var.aws_region))
  }
}

# AWS AZ (Should be elsewhere)
variable "aws_az" {
  type        = string
  description = "AWS Availability Zone"
  default     = "us-east-1c"
  validation {
    error_message = "Value must lower case and in the form of xx-xxxx-[1-3]"
    condition     = can(regex("[a-z]{2}-[gov-]?[a-z]{4}-[1-3][a-c]", var.aws_az))
  }

}

# RDS Region for backup. This example uses RDS but we need at least 2 AZs even though we're not
# deploying multi-az
variable "rds_backup_az" {
  type        = string
  description = "RDS Backupo Availability Zone"
  default     = "us-east-1c"
  validation {
    error_message = "Value must lower case and in the form of xx-xxxx-[1-3]"
    condition     = can(regex("[a-z]{2}-[gov-]?[a-z]{4}-[1-3][a-c]", var.rds_backup_az))
  }
}

# VPC Variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.1.64.0/18"
  validation {
    error_message = "Value is an invalid CIDR format, i.e., xx.xx.xx.xx/xx"
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(/(3[0-2]|[1-2][0-9]|[0-9]))$", var.vpc_cidr))
  }
}

# Subnet Variables
variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.1.64.0/24"
  validation {
    error_message = "Value is an invalid CIDR format, i.e., xx.xx.xx.xx/xx"
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(/(3[0-2]|[1-2][0-9]|[0-9]))$", var.public_subnet_cidr))
  }
}

# cidr for the rds backup subnet. rds requires two even though this example is not multi-az
variable "rds_backup_cidr" {
  type        = string
  description = "CIDR for the rds backup subnet"
  default     = "10.1.65.0/24"
  validation {
    error_message = "Value is an invalid CIDR format, i.e., xx.xx.xx.xx/xx"
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(/(3[0-2]|[1-2][0-9]|[0-9]))$", var.rds_backup_cidr))
  }
}

variable "timezone" {
  type    = string
  default = "Pacific Time Zone"
}

# EC2 (VM) Instance Variables and defaults.

variable "windows_instance_class" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t2.micro"
}

# RDS Instance type
variable "rds_instance_class" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "db.t3.large"
}

variable "windows_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}

variable "windows_root_volume_size" {
  type        = number
  description = "Size of root volume of Windows Server"
  default     = "30"
}

variable "windows_data_volume_size" {
  type        = number
  description = "Size of data volume of Windows Server"
  default     = "10"
}

variable "windows_volume_type" {
  type        = string
  description = "Type of volume for windows FS. Can be standard, gp3, gp2, io1, sc1 or st1"
  default     = "gp2"
}


variable "windows_instance_name" {
  type        = string
  description = "EC2 instance name for Windows Server"
  default     = "foowinsrv01"
  validation {
    error_message = "Value must not have spaces or tabs."
    condition     = !can(regex("\\s+", var.windows_instance_name))
  }
}

variable "databasename" {
  type    = string
  default = "testdb"
  validation {
    error_message = "Value must not have spaces or tabs."
    condition     = !can(regex("\\s+", var.databasename))
  }
}