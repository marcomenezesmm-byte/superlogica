import {
  to = aws_security_group.ec2_mysql_sg
  id = "sg-06cccdf7125822870"
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

import {
  to = aws_security_group.rds_mysql_sg
  id = "sg-08ef37dbe44208c60"
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