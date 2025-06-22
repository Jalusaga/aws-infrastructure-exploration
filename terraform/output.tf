output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.db.endpoint
}