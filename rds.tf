import {
  to = aws_db_subnet_group.default
  id = "demo-default-subnets"
}


resource "aws_db_subnet_group" "default" {
  name       = "${lower(var.project)}-default-subnets"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Project = var.project
  }
}

resource "random_password" "rds_master" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}



resource "aws_db_instance" "mysql" {
  identifier              = "${lower(var.project)}-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds_mysql_sg.id]
  publicly_accessible     = var.rds_publicly_accessible

  username = "admin"
  password = random_password.rds_master.result

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Project = var.project
  }
}

