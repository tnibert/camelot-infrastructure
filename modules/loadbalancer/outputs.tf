output "target_group_arn" {
  value = aws_lb_target_group.prod_backend.arn
}

output "security_group_id" {
  value = aws_security_group.prod_lb.id
}

output "dns_name" {
  value = aws_lb.prod.dns_name
}
