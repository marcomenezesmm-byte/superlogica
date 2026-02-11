terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ec2_mysql_sg" {
  name        = "${var.project}-ec2-mysql-sg"
  description = "EC2 SG: SSH and MySQL from allowed_cidr"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "MySQL (EC2)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project
  }
}

resource "aws_security_group" "rds_mysql_sg" {
  name        = "${var.project}-rds-mysql-sg"
  description = "RDS SG: MySQL from EC2 SG"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "MySQL from EC2 SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_mysql_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.project}-default-subnets"
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
  identifier              = "${var.project}-mysql"
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

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    dnf update -y
    dnf install -y docker

    systemctl enable docker
    systemctl start docker

    # Run MySQL in Docker (simple demo)
    docker pull mysql:8.0

    docker run -d --name mysql-demo \
      -e MYSQL_ROOT_PASSWORD='${var.mysql_container_password}' \
      -p 3306:3306 \
      --restart unless-stopped \
      mysql:8.0

    EOF
}

resource "aws_instance" "mysql_ec2" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_mysql_sg.id]

  key_name  = var.key_name != "" ? var.key_name : null
  user_data = local.user_data

  tags = {
    Name    = "${var.project}-mysql-ec2"
    Project = var.project
  }
}
