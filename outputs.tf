output "ec2_public_ip" {
  description = "Public IP of the EC2 instance (if assigned)."
  value       = try(aws_instance.mysql_ec2.public_ip, null)
}

output "rds_endpoint" {
  description = "RDS endpoint address."
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "RDS port."
  value       = aws_db_instance.mysql.port
}

output "rds_master_username" {
  description = "RDS master username."
  value       = aws_db_instance.mysql.username
}

output "rds_master_password" {
  description = "RDS master password (sensitive)."
  value       = random_password.rds_master.result
  sensitive   = true
}
