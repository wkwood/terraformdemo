output "vpc_id" {
  value = module.network.vpc_main_id
}

output "public_subnet_id" {
  value = module.network.vpc_public_subnet_id
}

output "windows_sg_id" {
  value = module.network.windows_sg_id
}

output "key_pair_id" {
  value = module.key-pair.key_pair_id
}

output "rds_db_endpoint" {
  value = module.RDS.db_instance_hostname
}

output "rds_db_admin_username" {
  value     = module.secrets.username
  sensitive = true
}
