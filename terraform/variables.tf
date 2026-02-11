variable "project" {
  description = "Project name prefix for resource naming."
  type        = string
  default     = "demo"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "allowed_cidr" {
  description = "CIDR allowed to access EC2 (SSH and MySQL). Example: 203.0.113.10/32"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional existing EC2 Key Pair name for SSH access."
  type        = string
  default     = ""
}

variable "mysql_container_password" {
  description = "Root password for MySQL container running on EC2."
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage (GiB)."
  type        = number
  default     = 20
}

variable "rds_publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible."
  type        = bool
  default     = false
}
