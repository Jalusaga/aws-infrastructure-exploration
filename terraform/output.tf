output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "db_address" {
  description = "Hostname of the RDS instance"
  value       = aws_db_instance.db.address  
}

output "db_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.db.port 
}

output "db_username" {
  description = "Username for the RDS database"
  value       = var.db_username
}

output "db_password" {
  description = "Password for the RDS database"
  value       = var.db_password
  sensitive   = true
}
