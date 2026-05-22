# Production cluster
resource "aws_ecs_cluster" "prod" {
  name = "prod"
}

# Backend web task definition and service
resource "aws_ecs_task_definition" "prod_backend_web" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family                = "backend-web"
  container_definitions = var.container_definitions
  execution_role_arn    = aws_iam_role.ecs_task_execution.arn
  task_role_arn         = aws_iam_role.prod_backend_task.arn
}

resource "aws_ecs_service" "prod_backend_web" {
  name                               = "prod-backend-web"
  cluster                            = aws_ecs_cluster.prod.id
  task_definition                    = aws_ecs_task_definition.prod_backend_web.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "prod-backend-web"
    container_port   = 8000
  }

  network_configuration {
    security_groups  = [aws_security_group.prod_ecs_backend.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }
}

# Security Group
resource "aws_security_group" "prod_ecs_backend" {
  name   = "prod-ecs-backend"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = var.ingress_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM roles and policies
resource "aws_iam_role" "prod_backend_task" {
  name = "prod-backend-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  inline_policy {
    name = "prod-backend-task-ssmmessages"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          },
          Effect = "Allow",
          Sid    = ""
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
