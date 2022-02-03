resource "aws_security_group" "spark_sg" {
  name        = "spark_sg"
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
      description      = "spark port"
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
    Name = "spark"
  }
}

data "aws_ami" "spark_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.spark_ami_name]
  }


  owners = [var.AMI_owner]
}


resource "aws_launch_configuration" "as_conf" {
  name_prefix                 = "csye6225-spark-lc-"
  image_id                     = data.aws_ami.spark_ami.id
  instance_type           = "t2.medium"
  security_groups  = [aws_security_group.spark_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.webapp_profile.name
  key_name                = var.key_pair_name
  associate_public_ip_address = true
  root_block_device {
    encrypted  = true
  }
  user_data               = <<EOF
#! /bin/bash
echo -e "#!/usr/bin/env bash" >> /home/ubuntu/spark-3.2.0-bin-hadoop3.2-scala2.13/conf/spark-env.sh
echo -e "export SPARK_MASTER_HOST=localhost" >> /home/ubuntu/spark-3.2.0-bin-hadoop3.2-scala2.13/conf/spark-env.sh
mv /home/ubuntu/spark-3.2.0-bin-hadoop3.2-scala2.13/conf/workers.template workers

echo -e "-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEAm3kxVt1ZBD0WOXUoqtxP47FT0cYzgz6u2ExWhxK+e7V/4uSjzzTi
IVp2mBaLuFn1TjsWjLXS2OkI2/QD5oTGHSOQX5kvoCcAPUYrS4WZtUvYkKnETedfs0Y574
4FXxrTCbDYk0E1mGOs+wnYTPHE2OcCwrEkk3fFLx4D1cpdGWiaqEs4neC23qko61L+gO3z
8kVzZ98wUB8RPhYoMLFDx8bCExlXiMwAhHABd0iqpS0NHiEF066LSgk3Dic4O3Uy6RcY1A
jpLy8EdCdU/7nbxmzEPqoEUZp5hcJ9/4Q7BDlnJ7RlldoAMwM8gJjDTGuFVrblzgkbfzB7
M7Szv9Fh2WZPI+11+RLaLZAUVq2AguoW0v+XjONyR+PVKHpx393FYua3/loJPbjiBtu1/a
UiuGI3QROuQWjOAFqtE/wWjS0XlOhU1HLjA6Lf0c0ItT5/kB4MZaoRRHXGaEwv386m2kJH
AFEzqvLcRFei5xm+dQY/SRe+EEio6s9l7bi6iFZTAAAFiOMAt+vjALfrAAAAB3NzaC1yc2
EAAAGBAJt5MVbdWQQ9Fjl1KKrcT+OxU9HGM4M+rthMVocSvnu1f+Lko8804iFadpgWi7hZ
9U47Foy10tjpCNv0A+aExh0jkF+ZL6AnAD1GK0uFmbVL2JCpxE3nX7NGOe+OBV8a0wmw2J
NBNZhjrPsJ2EzxxNjnAsKxJJN3xS8eA9XKXRlomqhLOJ3gtt6pKOtS/oDt8/JFc2ffMFAf
ET4WKDCxQ8fGwhMZV4jMAIRwAXdIqqUtDR4hBdOui0oJNw4nODt1MukXGNQI6S8vBHQnVP
+528ZsxD6qBFGaeYXCff+EOwQ5Zye0ZZXaADMDPICYw0xrhVa25c4JG38wezO0s7/RYdlm
TyPtdfkS2i2QFFatgILqFtL/l4zjckfj1Sh6cd/dxWLmt/5aCT244gbbtf2lIrhiN0ETrk
FozgBarRP8Fo0tF5ToVNRy4wOi39HNCLU+f5AeDGWqEUR1xmhML9/OptpCRwBRM6ry3ERX
oucZvnUGP0kXvhBIqOrPZe24uohWUwAAAAMBAAEAAAGAC8wld07yi0TLY+7E+DohgciZ8K
gWjpX6FIWuZy9/7sk1/BSXbYi4xAkmSKIlVgbVe2s2adT+O+Fq/63DggF/OwTQ1sA8Ae4T
sZKahG+N21j3BPss3zB4bZUdnlTriWzyqKCXvozLMVYW8TGtDSGna0IUTou8l8gV2V5wsg
9aAyyR18VldW1w0vKJHVo937CuuyqT+ETSWLISz+BEinVZDFbDsUlSABpiy6noIpIMCN6j
SS7+TzLGdQa/+730IWbiKNDIR11cihw9Y6tI7oQN35v3364YyXzjXJCsOPM5LKyH8DwgsO
5h6BsVw55iLr19L/WAsj5+zHwMpYwTtTfkTSPwLCkDxriLpjDpjZVQqHpZDQHeafyFDaSs
ymtXM2nVIRXqrRzY1EnVbTfAkcoNWYU1lgz58FAtTfQo8WJ3OKEl3ZwdgPZdc9SbP+l4q6
G9F5umPP2/EzDM8Wv4akURYECVoRzUNmVwgRiDV8PYQ5W1z4TX8DBvlq64+yQnwedxAAAA
wAPNESjtr0zaoowQdh3TotP/hk5+qXCIr1bqeVEH5M5uqKJXL+ZJQfP59KDEXUZs/bVd5H
xUjTF9xctLeCoUFIdthl0ooS1gV8yPjNGKTNdcMbxXPYpX2avrq4Xr01dmdBjpv4g5E92N
wNS8n2hsaLsZewDzwsbr2+18ST7HM1hivBEnnbcXZ0/GZnbMbxe3Th0qx3BY8QMivY6Aal
xctILwGpMGzWNOXyPchR7KZcZlD/w6xb4Cbk98QToX9FarTQAAAMEAyCOuiKEuS0l1tLen
4DOvn8X+F0Oy5qf6cLgSXNaw/kIHkhbXRmEsL8qXtAlbKGeEFbjChx+I+00PhrQPAl8BgR
p9SQ8zdDnOyc+0L0fKzCoWUfCW2Gkg9jzRpDUuqSWqV0rS8Vwpd3uIVsSxLRw9gsbnmDea
XVaXt+bYmlnndks1CErrmtISyq6beBKonegPQ/tcVH42uBtIsZGHA0Cz7YhNCrUVTm+zI2
kQap7rx6QB5kW6/dJ512XdY+iik2Y5AAAAwQDG3gwH4nVe45NisI8fKhwbb/oCpVrBtFGa
kqRiNFqDsNEoK3wIYIn2TPv3bwmRu2y3gtB2QyRNRy2dNocf/wn2lCFU9t6dIP3dUEUNDC
AuVULKHCjQVK9pjVr5ETzlBZqCUJg+fJB9xqgjPKkAYJS4R87zhnhpmVyGQOxvkwSqqBnm
jENVVIBr6hH6dObNwSqua5any/JixAOYuNCXFfjUBOIJqaP8k0dEZjxml4vSS3dWo0xFqb
mLpha6PyMFgOsAAAATdWJ1bnR1QGlwLTEwLTAtMS0xNQ==
-----END OPENSSH PRIVATE KEY-----" >> /home/ubuntu/.ssh/id_rsa
echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCbeTFW3VkEPRY5dSiq3E/jsVPRxjODPq7YTFaHEr57tX/i5KPPNOIhWnaYFou4WfVOOxaMtdLY6Qjb9APmhMYdI5BfmS+gJwA9RitLhZm1S9iQqcRN51+zRjnvjgVfGtMJsNiTQTWYY6z7CdhM8cTY5wLCsSSTd8UvHgPVyl0ZaJqoSzid4LbeqSjrUv6A7fPyRXNn3zBQHxE+FigwsUPHxsITGVeIzACEcAF3SKqlLQ0eIQXTrotKCTcOJzg7dTLpFxjUCOkvLwR0J1T/udvGbMQ+qgRRmnmFwn3/hDsEOWcntGWV2gAzAzyAmMNMa4VWtuXOCRt/MHsztLO/0WHZZk8j7XX5EtotkBRWrYCC6hbS/5eM43JH49UoenHf3cVi5rf+Wgk9uOIG27X9pSK4YjdBE65BaM4AWq0T/BaNLReU6FTUcuMDot/RzQi1Pn+QHgxlqhFEdcZoTC/fzqbaQkcAUTOq8txEV6LnGb51Bj9JF74QSKjqz2XtuLqIVlM= ubuntu" >> /home/ubuntu/.ssh/authorized_keys
cp -r /home/ubuntu/.ssh /root
chmod 600 /root/.ssh/id_rsa

nohup /home/ubuntu/spark-3.2.0-bin-hadoop3.2-scala2.13/sbin/start-all.sh > ~/spark.log 2>&1 &
/home/ubuntu/spark-3.2.0-bin-hadoop3.2-scala2.13/sbin/start-all.sh


echo -e "KAFKA_IP=${aws_instance.kafka["0"].private_ip}" >> /home/ubuntu/.env
echo -e "KAFKA_IP1=${aws_instance.kafka["1"].private_ip}" >> /home/ubuntu/.env
echo -e "KAFKA_IP2=${aws_instance.kafka["2"].private_ip}" >> /home/ubuntu/.env
echo -e "MYSQL_URL=${aws_db_instance.mysql.address}" >> /home/ubuntu/.env
echo -e "MYSQL_USER=${aws_db_instance.mysql.username}" >> /home/ubuntu/.env
echo -e "MYSQL_PW=${aws_db_instance.mysql.password}" >> /home/ubuntu/.env
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_spark" {
  name                 = "csye6225-asg-spark"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 1
  max_size             = 8
  desired_capacity     = 1
  default_cooldown     = 600
  vpc_zone_identifier  = [aws_subnet.subnet["us-east-1a"].id]
  target_group_arns    = ["${aws_lb_target_group.spark_target_group.arn}"]
  tag {
    key                 = "Name"
    value               = "spark"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "agents-scale-up" {
  name                   = "agents-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_spark.name
}

resource "aws_autoscaling_policy" "agents-scale-down" {
  name                   = "agents-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_spark.name
}


resource "aws_cloudwatch_metric_alarm" "CPU-high" {
  alarm_name          = "mem-util-high-agents"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"
  alarm_description   = "This metric monitors ec2 CPU for high utilization on agent hosts"
  alarm_actions = [
    "${aws_autoscaling_policy.agents-scale-up.arn}"
  ]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg_spark.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory-low" {
  alarm_name          = "mem-util-low-agents"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "This metric monitors ec2 memory for low utilization on agent hosts"
  alarm_actions = [
    "${aws_autoscaling_policy.agents-scale-down.arn}"
  ]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg_spark.name}"
  }
}