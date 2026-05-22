variable "prod_rds_db_name" {
  description = "RDS database name"
  default     = "django_aws"
}

variable "prod_rds_username" {
  description = "RDS database username"
  default     = "django_aws"
}

variable "prod_rds_password" {
  description = "postgres password for production DB"
}

variable "prod_rds_instance_class" {
  description = "RDS instance type"
  default     = "db.t2.micro"
}

variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "security_groups" {
  description = "The security groups"
  default     = []
}

variable "subnet_ids" {
  description = "The subnet IDs"
  default     = []
}
