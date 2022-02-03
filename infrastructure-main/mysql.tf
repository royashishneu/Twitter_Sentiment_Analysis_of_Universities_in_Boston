
resource "aws_security_group" "database" {
  name        = "database"
  description = "Allow database inbound traffic"
  vpc_id      = aws_vpc.csye7200.id

  ingress = [
    {
      description      = "MySQL"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "database"
  }
}


resource "aws_db_parameter_group" "mysql_pg" {
  name   = "rds-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

}

resource "aws_db_subnet_group" "mysql_sg" {
  name       = "mysql_sg"
  subnet_ids = [aws_subnet.subnet["us-east-1b"].id, aws_subnet.subnet["us-east-1c"].id]

  tags = {
    Name = "My DB subnet group"
  }
}


resource "aws_db_instance" "mysql" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  multi_az               = false
  name                   = "csye7200"
  username               = "csye7200"
  password               = "mACnZipEZ3EEVmpyMYKH__f"
  db_subnet_group_name   = aws_db_subnet_group.mysql_sg.name
  publicly_accessible    = true
  parameter_group_name   = aws_db_parameter_group.mysql_pg.name
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  skip_final_snapshot    = true
}