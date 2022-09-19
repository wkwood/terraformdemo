# inputs

variable "app_name" {}
variable "app_environment" {}
variable "aws_region" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "aws_az" {}
variable "rds_backup_az" {}
variable "rds_backup_cidr" {}


# Single network AZ configuration

# Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc"
    Environment = var.app_environment
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.aws_az
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-public-subnet"
    Environment = var.app_environment
  }
}

# Define the rds backup subnet
resource "aws_subnet" "rds-backup-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.rds_backup_cidr
  availability_zone = var.rds_backup_az
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-rds-backup-subnet"
    Environment = var.app_environment
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-igw"
    Environment = var.app_environment
  }
}

# Define the public route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name        = "${lower(var.app_name)}-${lower(var.app_environment)}-public-subnet-rt"
    Environment = var.app_environment
  }
}

# Assign the public route table to the public subnet
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# Define the default security group we will use for later.

resource "aws_security_group" "aws-windows-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-windows-sg"
  description = "Allow incoming connections"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "http allowed inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
  }

  egress {
    description = "allow any traffic outbound via the IGW"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-windows-sg"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "aws-rds-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-rds-sg"
  description = "Allow incoming/outgoing connections for RDS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-rds-sg"
    Environment = var.app_environment
  }
}