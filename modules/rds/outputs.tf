output "rds_db_name" {
  value = var.prod_rds_db_name
}

output "rds_username" {
  value = var.prod_rds_username
}

output "rds_password" {
  value = var.prod_rds_password
}

output "rds_hostname" {
  value = aws_db_instance.prod.address
}
