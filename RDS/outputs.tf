output "db_instance_hostname" {
  value = aws_db_instance.rds.address
}

output "db_port" {
  value = aws_db_instance.rds.port
}

output "db_admin_username" {
  value = aws_db_instance.rds.username
}