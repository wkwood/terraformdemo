# Output variables. These can feed other things

output "vpc_main_id" {
  value = aws_vpc.vpc.id
}

output "vpc_public_subnet_id" {
  value = aws_subnet.public-subnet.id
}

output "rds_backup_subnet_id" {
  value = aws_subnet.rds-backup-subnet.id
}

output "windows_sg_id" {
  value = aws_security_group.aws-windows-sg.id
}

output "rds_sg_id" {
  value = aws_security_group.aws-rds-sg.id
}