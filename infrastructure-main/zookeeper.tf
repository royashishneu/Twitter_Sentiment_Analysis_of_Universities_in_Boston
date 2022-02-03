resource "aws_security_group" "zookeeper_sg" {
  name        = "zookeeper_sg"
  description = "Only allow traffic from subnet"
  vpc_id      = aws_vpc.csye7200.id

  ingress = [
    {
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "zookeeper port"
      from_port        = 2181
      to_port          = 2181
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.csye7200.cidr_block]
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
    Name = "zookeeper"
  }
}

data "aws_ami" "zookeeper_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.zookeeper_ami_name]
  }


  owners = [var.AMI_owner]
}

resource "aws_iam_role" "zookeeper_role" {
  name               = "zookeeper_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "zookeeper_profile" {
  name = "zookeeper_role"
  role = aws_iam_role.zookeeper_role.name
}

resource "aws_instance" "zookeeper" {
  ami                     = data.aws_ami.zookeeper_ami.id
  instance_type           = "t2.medium"
  disable_api_termination = false
  subnet_id               = aws_subnet.subnet["us-east-1a"].id
  vpc_security_group_ids  = [aws_security_group.zookeeper_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.zookeeper_profile.name
  key_name                = var.key_pair_name
  user_data               = <<EOF
#! /bin/bash
/home/ubuntu/apache-zookeeper-3.5.9-bin/bin/zkServer.sh start
EOF

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
  tags = {
    Name = "zookeeper"
  }
}