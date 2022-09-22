# Overrides for defaults previously defined. 
# It's important that these change as required for isolation in terms of this
# IAC setup.

# Application Definition 
app_name        = "testcloud" # No spaces
app_environment = "dev"       # For naming, Dev, Test, Staging, Prod, etc

# Network
vpc_cidr           = "10.20.0.0/16"
public_subnet_cidr = "10.20.1.0/24"
rds_backup_cidr    = "10.20.2.0/24"

aws_region    = "us-west-2"
aws_az        = "us-west-2c"
rds_backup_az = "us-west-2b"
timezone      = "Pacific Standard Time" # SQL Server/Windows EC2 instance specific.


# Windows Virtual Machine
windows_instance_name               = "devwinsrv01"
windows_instance_class              = "t3.xlarge"
rds_instance_class                  = "db.t3.large"
windows_associate_public_ip_address = true
windows_root_volume_size            = 30
windows_volume_type                 = "gp2"
windows_data_volume_size            = 30
