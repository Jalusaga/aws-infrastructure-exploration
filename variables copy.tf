variable "main-region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "private_azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.5.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "yourusername"
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  default     = "changeme"
  sensitive   = true
}

