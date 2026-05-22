variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "public_subnet_ids" {
  description = "The public subnet IDs"
  default     = []
}

variable "private_subnet_ids" {
  description = "The private subnet IDs"
  default     = []
}

variable "container_definitions" {
  description = "The container definition to run in ECS"
}

variable "lb_target_group_arn" {}

variable "ingress_security_groups" {
  default = []
}
