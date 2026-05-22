module "rds" {
  source = "./modules/rds"

  subnet_ids        = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]
  security_groups   = [module.ecs.security_group_id]
  vpc_id            = aws_vpc.prod.id
  prod_rds_password = var.prod_rds_password
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id             = aws_vpc.prod.id
  public_subnet_ids  = [aws_subnet.prod_public_1.id, aws_subnet.prod_public_2.id]
  private_subnet_ids = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]

  lb_target_group_arn     = module.load_balancer.target_group_arn
  ingress_security_groups = [module.load_balancer.security_group_id]

  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    {
      region     = var.region
      name       = "prod-backend-web"
      image      = aws_ecr_repository.backend.repository_url
      command    = ["gunicorn", "-w", "3", "-b", ":8000", "projectcamelot.wsgi:application"]
      log_group  = aws_cloudwatch_log_group.prod_backend.name
      log_stream = aws_cloudwatch_log_stream.prod_backend_web.name

      rds_db_name  = module.rds.rds_db_name
      rds_username = module.rds.rds_username
      rds_password = module.rds.rds_password
      rds_hostname = module.rds.rds_hostname
    },
  )
}

module "load_balancer" {
  source = "./modules/loadbalancer"

  subnet_ids = [aws_subnet.prod_public_1.id, aws_subnet.prod_public_2.id]
  vpc_id     = aws_vpc.prod.id
}

# Cloudwatch Logs
resource "aws_cloudwatch_log_group" "prod_backend" {
  name              = "prod-backend"
  retention_in_days = var.ecs_prod_backend_retention_days
}

resource "aws_cloudwatch_log_stream" "prod_backend_web" {
  name           = "prod-backend-web"
  log_group_name = aws_cloudwatch_log_group.prod_backend.name
}
