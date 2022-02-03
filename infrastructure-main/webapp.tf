resource "aws_security_group" "webapp_sg" {
  name        = "webapp_sg"
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
      description      = "http"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "webapp port"
      from_port        = 3000
      to_port          = 3000
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
    Name = "webapp"
  }
}

data "aws_ami" "webapp_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.webapp_ami_name]
  }


  owners = [var.AMI_owner]
}

resource "aws_iam_role" "webapp_role" {
  name               = "webapp_role"
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

resource "aws_iam_instance_profile" "webapp_profile" {
  name = "webapp_role"
  role = aws_iam_role.webapp_role.name
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy-webapp-attach" {
  role       = aws_iam_role.webapp_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


resource "aws_instance" "webapp" {
  ami                     = data.aws_ami.webapp_ami.id
  instance_type           = "t2.medium"
  disable_api_termination = false
  subnet_id               = aws_subnet.subnet["us-east-1a"].id
  vpc_security_group_ids  = [aws_security_group.webapp_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.webapp_profile.name
  key_name                = var.key_pair_name
  user_data               = <<EOF
#! /bin/bash
mkdir /home/ubuntu/webapp/
sudo chmod -R 777 /home/ubuntu/webapp/
echo -e "CONSUMER_KEY=${var.consumer_key}" >> /home/ubuntu/webapp/.env
echo -e "CONSUMER_SECRET=${var.consumer_secret}" >> /home/ubuntu/webapp/.env
echo -e "TWITTER_ACCESS_TOKEN=${var.twitter_access_token}" >> /home/ubuntu/webapp/.env
echo -e "TWITTER_ACCESS_SECRET=${var.twitter_access_secret}" >> /home/ubuntu/webapp/.env
echo -e "KAFKA_IP0=${aws_instance.kafka["0"].private_ip}" >> /home/ubuntu/webapp/.env
echo -e "KAFKA_IP1=${aws_instance.kafka["1"].private_ip}" >> /home/ubuntu/webapp/.env
echo -e "KAFKA_IP2=${aws_instance.kafka["2"].private_ip}" >> /home/ubuntu/webapp/.env
echo -e "DB_USER=${aws_db_instance.mysql.username}" >> /home/ubuntu/webapp/.env
echo -e "DB_PW=${aws_db_instance.mysql.password}" >> /home/ubuntu/webapp/.env
echo -e "DB_HOST=${aws_db_instance.mysql.address}" >> /home/ubuntu/webapp/.env
echo -e "{
    \"agent\": {
        \"metrics_collection_interval\": 10,
        \"logfile\": \"/var/logs/amazon-cloudwatch-agent.log\"
    },
    \"logs\": {
        \"logs_collected\": {
            \"files\": {
                \"collect_list\": [
                    {
                        \"file_path\": \"/var/log/cloud-init-output.log\",
                        \"log_group_name\": \"csye7200\",
                        \"log_stream_name\": \"webapp-init\"
                    }
                ]
            }
        },
        \"log_stream_name\": \"cloudwatch_log_stream\"
    }
}" >> /home/ubuntu/default_cw_config.json
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/home/ubuntu/default_cw_config.json
EOF

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
  tags = {
    Name = "webapp"
  }
}

