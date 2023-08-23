variable "region" {
  description = "The AWS region to create resources in."
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Project name to use in resource names"
  default     = "camelot"
}

variable "availability_zones" {
  description = "Availability zones"
  default     = ["ap-southeast-2a", "ap-southeast-2c"]
}

variable "ecs_prod_backend_retention_days" {
  description = "Retention period for backend logs"
  default     = 30
}