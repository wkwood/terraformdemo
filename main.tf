
# build out the key pair file

module "key-pair" {
  source          = "./key-pair"
  app_name        = var.app_name
  app_environment = var.app_environment
  aws_region      = var.aws_region
}

# build out the VPC, establish the subnets and build the security groups

module "network" {
  source             = "./network"
  app_name           = var.app_name
  app_environment    = var.app_environment
  aws_region         = var.aws_region
  aws_az             = var.aws_az
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  rds_backup_az      = var.rds_backup_az
  rds_backup_cidr    = var.rds_backup_cidr
}

module "S3" {
  source          = "./S3"
  app_name        = var.app_name
  app_environment = var.app_environment
  region          = var.aws_region
}

module "secrets" {
  source          = "./secrets"
  app_name        = var.app_name
  app_environment = var.app_environment
}

# build the windows server instance

module "EC2" {
  source                              = "./EC2"
  security_group_id                   = module.network.windows_sg_id
  app_name                            = var.app_name
  app_environment                     = var.app_environment
  windows_instance_name               = var.windows_instance_name
  windows_instance_class              = var.windows_instance_class
  windows_associate_public_ip_address = var.windows_associate_public_ip_address
  windows_volume_type                 = var.windows_volume_type
  windows_root_volume_size            = var.windows_root_volume_size
  windows_data_volume_size            = var.windows_data_volume_size
  public_subnet_id                    = module.network.vpc_public_subnet_id
  key_pair_id                         = module.key-pair.key_pair_id
  transit_role_name                   = module.S3.transit_role_name
  timezone                            = var.timezone
}

# build out the RDS SQLServer instance

module "RDS" {
  source               = "./RDS"
  rds_subnet_id        = module.network.vpc_public_subnet_id
  rds_backup_subnet_id = module.network.rds_backup_subnet_id
  rds_sg_id            = module.network.rds_sg_id
  vpc_id               = module.network.vpc_main_id
  rds_instance_class   = var.rds_instance_class
  timezone             = var.timezone
  databasename         = var.databasename
  vpc_cidr             = var.vpc_cidr
  app_name             = var.app_name
  app_environment      = var.app_environment
  admin_username       = module.secrets.username
  admin_password       = module.secrets.password
}
