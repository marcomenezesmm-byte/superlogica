


resource "aws_instance" "mysql_ec2" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_mysql_sg.id]

  key_name  = var.key_name != "" ? var.key_name : null

  tags = {
    Name    = "${var.project}-mysql-ec2"
    Project = var.project
  }
}